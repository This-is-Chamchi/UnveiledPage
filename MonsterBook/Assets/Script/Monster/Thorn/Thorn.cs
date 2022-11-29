using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using MonsterFSM;
using UnityEngine.Rendering;

public class Thorn : AttackMonster
{

    private bool AttackCheck = false;
    private float CurrentAttackTime;

    protected override void Start()
    {
        base.Start();
        FSM = MonsterFSMCreator.MonsterPatrolFSM(this);
    }

    protected override void Update()
    {
        base.Update();
        SetEffect();

        if (transform.rotation.eulerAngles.y < 180)
        {
            transform.rotation = Quaternion.Euler(new Vector3(0.0f, 90.0f, 0.0f));            
        }
        else
        {
            transform.rotation = Quaternion.Euler(new Vector3(0.0f, -90.0f, 0.0f));            
        }

        if (gFSM is Monster_NormalAttack)
        {
            CurrentAttackTime += Time.deltaTime;
            if (CurrentAttackTime >= 0.4f)
                AttackCheck = true;
        }
        else
        {
            AttackCheck = false;
            CurrentAttackTime = 0.0f;
        }
    }

    private void SetEffect()
    {
        bool IsAttack = FSM is Monster_NormalAttack;
        if (IsAttack)
        {
            if (gAnimationTrigger.gEffectEvent)
                gEffects[0].SetActive(true);
        }
        else
        {
            gEffects[0].SetActive(false);
        }
    }

    protected override MonsterFSMBase Transition()
    {

        if (FSM is Monster_Hit)
        {
            return FSMHit();
        }
        if (FSM is Monster_Patrol)
        {
            return FSMPatrol();
        }
        if (FSM is Monster_Idle)
        {
            return FSMIdle();
        }
        if (FSM is Monster_FollowPlayer)
        {
            return FSMIdle();
        }
        if (FSM is Monster_NormalAttack)
        {
            return FSMNormalAttack();
        }



        return FSM;
    }


    public override void OnDamage(int damage, Vector3 pos)
    {
        EffectPoolManager.gInstance.LoadEffect("FX_Hit_Enemy", transform);


        if (AttackCheck == false)
        {
            if (gHP >= 0)
                gExplosionVector = pos;

            gHP -= damage;

            if (gHP >= 0)
            {
                gAnimationTrigger.init();
                FSM = MonsterFSMCreator.MonsterHitFSM(this);
                HitSound();
            }
        }
    }
    #region Transition
    private MonsterFSMBase FSMPatrol()
    {
        var NewTime = Time.time;
        var Patrol = FSM as Monster_Patrol;


        var AttackFSM = AttackFSMTransition();
        if (AttackFSM != null)
            return AttackFSM;


        var VisitePatrolPoint = Patrol != null ? Patrol.gVisitePatrolPoint : false;
        if (VisitePatrolPoint)
        {
            return MonsterFSMCreator.MonsterIdleFSM(this);
        }

        return FSM;
    }

    private MonsterFSMBase FSMIdle()
    {
        float NewTime = Time.time;

        var AttackFSM = AttackFSMTransition();
        if (AttackFSM != null)
            return AttackFSM;


        if (NewTime - FSM.gFSMStart > gIdleTime)
        {
            if (!gFindMonsterScript.gIsPlayerChecker)
                return MonsterFSMCreator.MonsterPatrolFSM(this);
        }
        return FSM;
    }

    private MonsterFSMBase FSMFollowPlayer()
    {
        var AttackFSM = AttackFSMTransition();
        if (AttackFSM != null)
            return AttackFSM;


        return FSM;
    }

    private MonsterFSMBase FSMHit()
    {
        if (gAnimationTrigger.gisAnimationEnd)
        {
            return MonsterFSMCreator.MonsterPatrolFSM(this);
        }
        return FSM;
    }



    private MonsterFSMBase FSMNormalAttack()
    {
        if (gAnimationTrigger.gisAnimationEnd)
        {
            var AttackFSM = AttackFSMTransition();
            if (AttackFSM != null)
                return AttackFSM;
        }
        return FSM;
    }


    #endregion

    private MonsterFSMBase AttackFSMTransition()
    {
        float NewTime = Time.time;

        if (gAttackChecer.gIsPlayerChecker)
        {
            if (NewTime - gCurrentAttackDelay > gAttackDelay)
            {
                SoundManager.PlayVFXSound("1Stage_SpikeWorm_Attack", transform.position);
                return MonsterFSMCreator.MonsterNormalAttack(this);
            }
            else
            {
                if (FSM is Monster_Idle)
                    return null;
                return MonsterFSMCreator.MonsterIdleFSM(this);
            }

        }
        else if (gFindMonsterScript.gIsPlayerChecker)
        {
            if (FSM is Monster_FollowPlayer)
                return null;
            return MonsterFSMCreator.MonsterFollowPlayerFSM(this);
        }
        return null;
    }

    protected override void DeadSound()
    {
        SoundManager.PlayVFXSound("1Stage_SpikeWorm_Dead", transform.position);
    }

    protected override void HitSound()
    {
        SoundManager.PlayVFXSound("1Stage_SpikeWorm_Hit", transform.position);
    }
}
