using System.Collections;
using System.Collections.Generic;
using MonsterFSM;
using UnityEngine;


public class MatcheCase : Non_AttackMonster
{
    [SerializeField]
    private GameObject MatcheFire;
    [SerializeField]
    private float SpawnTime;
    [SerializeField]
    private FindActor gFindActor;
    [SerializeField]
    private int FireBugAmount;
    [SerializeField]
    private float ReSpawnTime;
    
    private int BugCount;
    private float CurrentTime;
    private float CurrentReSpawnTime;
    private Vector3 SpawnDirection;
    private Quaternion SpawnRot;

    private GameObject[] Matches;
    protected override void Start()
    {
        base.Start();
        FSM = MonsterFSMCreator.MonsterIdleFSM(this);        
        SpawnDirection = transform.position + transform.forward * 4;
        SpawnRot = Quaternion.identity;
        CurrentReSpawnTime = ReSpawnTime;
        Matches = new GameObject[FireBugAmount];
    }

    protected override void Update()
    {
        base.Update();
        BugCheck();

        if (FSM is Monster_Dead == false)
        {
            if (gFindActor.gIsPlayerChecker && BugCount < FireBugAmount && CurrentReSpawnTime > ReSpawnTime)
            {
                //gAnimationTrigger.gisEvent
                if (CurrentTime > SpawnTime)
                {
                    gAnimator.SetTrigger("Spawn");
                    SoundManager.PlayVFXSound("2Stage_MatchBox_Summon" , transform.position);
                    var rot = Quaternion.LookRotation(gFindActor.gTargetPos - SpawnDirection);
                    rot.eulerAngles = Vector3.Scale(rot.eulerAngles, Vector3.up);

                    Matches[BugCount] = Instantiate(MatcheFire, SpawnDirection, rot);
                    BugCount++;
                    CurrentTime = 0.0f;
                    SetEffect();
                }
            }
        }
        CurrentReSpawnTime += Time.deltaTime;
        CurrentTime += Time.deltaTime;
    }
    private void SetEffect()
    {
        
    }

    private void BugCheck()
    {
        if (BugCount == FireBugAmount)
        {

            int count = BugCount;
            foreach (var item in Matches)
            {
                if (item == null)
                    count--;                
            }
            if (count == 0)
            {
                
                CurrentReSpawnTime = 0.0f;
                BugCount = 0;
            }

        }
    }
    protected override MonsterFSMBase Transition()
    {
        return FSM;
    }

    protected override void DeadSound()
    {
        SoundManager.PlayVFXSound("2Stage_MatchBox_Dead", transform.position);
    }

    protected override void HitSound()
    {
        SoundManager.PlayVFXSound("2Stage_MatchBox_Hit", transform.position);
    }
}
