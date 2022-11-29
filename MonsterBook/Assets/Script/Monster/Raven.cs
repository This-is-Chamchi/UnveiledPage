using System.Collections;
using System.Collections.Generic;
using MonsterFSM;
using UnityEngine;

public class Raven : AttackMonster
{

    private bool IsAttack;
    private float CurrentIdleTime;
    
    protected override void Start()
    {
        base.Start();
        gCurrentAttackDelay = gAttackDelay;
        CurrentIdleTime = gIdleTime;
        FSM = MonsterFSMCreator.MonsterFlyIdleFSM(this);
        //SoundManager.PlayVFXLoopSound("2Stage_Crow_Flapping", transform);
    }
    protected override void Update()
    {
        base.Update();
        gCurrentAttackDelay += Time.deltaTime;
        

        if (gFSM is Monster_FlyingAttack)
        {
            if (gAttackChecer.gIsPlayerChecker)
            {
                if (!IsAttack)
                {
                    gAttackChecer.PlayerOnDamage();
                    IsAttack = true;
                }
            }
        }
        else
        {
            IsAttack = false;
        }

        if (gFSM is Monster_Flying)
        {
            CurrentIdleTime += Time.deltaTime;
        }
    }
    protected override MonsterFSMBase Transition()
    {
        if (FSM is Monster_Patrol)
        {

            var Patrol = FSM as Monster_Patrol;
            var VisitePatrolPoint = Patrol != null ? Patrol.gVisitePatrolPoint : false;

            if (VisitePatrolPoint)
            {
                return MonsterFSMCreator.MonsterFlyIdleFSM(this);
            }
            else if (gFindMonsterScript.gIsPlayerChecker && gCurrentAttackDelay > gAttackDelay)
            {
                CurrentIdleTime = 0.0f;
                gCurrentAttackDelay = 0.0f;
                SoundManager.PlayVFXSound("2Stage_Crow_Cawing", transform.position);
                return MonsterFSMCreator.MonsterFlyAttack(this);
            }
        }

        if (gFSM is Monster_Flying)
        {
            var Flaying = gFSM as Monster_Flying;
            if (gFindMonsterScript.gIsPlayerChecker && gCurrentAttackDelay > gAttackDelay && Flaying.g_End)
            {
                CurrentIdleTime = 0.0f;
                gCurrentAttackDelay = 0.0f;
                SoundManager.PlayVFXSound("2Stage_Crow_Cawing", transform.position);
                return MonsterFSMCreator.MonsterFlyAttack(this);
            }
            else if (CurrentIdleTime >= gIdleTime)
            {
                CurrentIdleTime = 0.0f;
                return MonsterFSMCreator.MonsterPatrolFSM(this);
            }
        }
        if (gFSM is Monster_FlyingAttack)
        {
            var AttackFSM = gFSM as MonsterFSMAttack;
            if (AttackFSM.gAttackEnd)
            {
                return MonsterFSMCreator.MonsterFlyIdleFSM(this);
            }

        }
        if (gFSM is Monster_Hit)
        {
            if (gAnimationTrigger.gisAnimationEnd)
            {
                Debug.Log(gAnimationTrigger.gisAnimationEnd);
                return MonsterFSMCreator.MonsterFlyIdleFSM(this);
            }
        }

        return gFSM;
    }

    protected void SetEffect()
    {
        if (gFSM is Monster_FlyingAttack)
        {
            gEffects[0].SetActive(true);
        }
        else
        {
            gEffects[0].SetActive(false);
        }
    }
    protected override void DeadSound()
    {
        SoundManager.PlayVFXSound("2Stage_Crow_Dead", transform.position);
        //SoundManager.StopVFXLoopSound("2Stage_Crow_Flapping");
    }

    protected override void HitSound()
    {
        SoundManager.PlayVFXSound("2Stage_Crow_Hit", transform.position);
    }
}
