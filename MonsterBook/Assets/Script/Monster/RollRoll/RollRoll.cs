using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using MonsterFSM;
using MonsterFSM.RollRollFSM;
using UnityEngine.Rendering.Universal;
using LDS;

public class RollRoll : Non_AttackMonster
{
    [SerializeField]
    private GameObject ObstacleObj;
    [SerializeField]
    private float CreateObstacleTime;
    [SerializeField]
    private float DestoryObstacleTime;
    [SerializeField]
    private float CurrentObstacle;
    [SerializeField]
    private int Damage;

    private Transform PlayerTrans;

    private bool isRunningCheck;

    private int CrySoundID;
    private int ScreamSoundID;


    private bool gIsChase { get; set; } = false;

    protected override void Start()
    {
        base.Start();
        FSM = MonsterFSMCreator.MonsterPatrolFSM(this);
        PlayerTrans = GameObject.FindWithTag("Player").transform;
    }


    protected override void Update()
    {
        base.Update();
        SetEffect();
        if (FSM is Monster_Running)
        {
            CreateObstacle();
        }


    }

    private void CreateObstacle()
    {
        CurrentObstacle += Time.deltaTime;
        if (CurrentObstacle >= CreateObstacleTime)
        {
            SoundManager.PlayVFXSound("1Stage_Lollol_Drop", transform.position);
            var Dir = (PlayerTrans.position - transform.position).normalized;
            var Cube = Instantiate(ObstacleObj, transform.position + Vector3.up, Quaternion.identity);
            var Force = Vector3.Scale(Dir, new Vector3(1.0f, 0.0f, 0.0f)) + Vector3.up * 5;
            Cube.GetComponent<Rigidbody>().AddForce(Force.normalized * 7, ForceMode.Impulse);
            Cube.GetComponent<RollRollObstacle>().Init(Damage);
            Destroy(Cube, DestoryObstacleTime);
            CurrentObstacle = 0.0f;
        }
    }

    private void SetEffect()
    {
        bool IsRunning = FSM is Monster_Running;
        bool IsIdle = FSM is Monster_Idle;

        if (IsRunning)
        {
            gEffects[0].SetActive(true);
        }
        else
        {
            gEffects[0].SetActive(false);
        }

        if (IsIdle)
        {
            gEffects[1].SetActive(true);
        }
        else
        {
            gEffects[1].SetActive(false);
        }
    }




    protected override MonsterFSMBase Transition()
    {
        if (FSM is Monster_Idle)
        {
            return FSMIdle();
        }
        if (FSM is Monster_Hit)
        {
            return FSMHit();
        }
        if (FSM is Monster_Patrol)
        {
            return FSMPatrol();
        }
        if (FSM is Monster_Running)
        {
            
            return FSMRunning();
        }

        return FSM;
    }

    
    private MonsterFSMBase FSMIdle()
    {
        float EndTime = Time.time;

        if (EndTime - FSM.gFSMStart > gIdleTime)
        {
            return MonsterFSMCreator.MonsterPatrolFSM(this);
        }
        return FSM;
    }

    private MonsterFSMBase FSMRunning()
    {
        return FSM; 
    }

    private MonsterFSMBase FSMPatrol()
    {

        var Patrol = FSM as Monster_Patrol;
        var VisitePatrolPoint = Patrol != null ? Patrol.gVisitePatrolPoint : false;

        if (VisitePatrolPoint)
        {
            return MonsterFSMCreator.MonsterIdleFSM(this);
        }
        return FSM;
    }

    private MonsterFSMBase FSMHit()
    {
        if (!gIsChase)
            gIsChase = true;

        if (gAnimationTrigger.gisAnimationEnd)
        {
            if (FSM is Monster_Running == false && !isRunningCheck)
            {
                CrySoundID = SoundManager.PlayVFXLoopSound("1Stage_Lollol_Cry", transform);
                ScreamSoundID = SoundManager.PlayVFXLoopSound("1Stage_Lollol_Scream", transform);
                isRunningCheck = true;
            }
            return MonsterFSMCreator.MonsterRunningFSM(this);
        }
        return FSM;
    }

    protected override void DeadSound()
    {        
        SoundManager.PlayVFXSound("1Stage_Lollol_Dead", transform.position);
        SoundManager.StopVFXLoopSound(CrySoundID);
        SoundManager.StopVFXLoopSound(ScreamSoundID);
    }
    protected override void HitSound()
    {
        SoundManager.PlayVFXSound("1Stage_Lollold_Hit", transform.position);
    }
}
