using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using MonsterFSM.MacaronFSM;
using MonsterFSM;

public class Macaron : AttackMonster
{
    [SerializeField]
    private Transform MacarongModle;
    protected override void Start()
    {
        base.Start();
        FSM = MonsterFSMCreator.MonsterIdleFSM(this);
        SoundManager.PlayVFXLoopSound("1Stage_Macarong_Move", transform);

    }


    protected override void Update()
    {
        base.Update();
        SetEffect();

        var rotationY = transform.rotation.eulerAngles.y;
        
        if (rotationY < 180)
        {
            MacarongModle.rotation = Quaternion.Euler(new Vector3(0.0f, 200, 0.0f));            
        }
        else
        {
            MacarongModle.rotation = Quaternion.Euler(new Vector3(0.0f, 270.0f, 0.0f));            
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



    private MonsterFSMBase FSMIdle()
    {
        float NewTime = Time.time;

        var AttackFSM = AttackFSMTransition();
        if (AttackFSM != null)
            return AttackFSM;

        return FSM;
    }

    private MonsterFSMBase FSMHit()
    {
        if (gAnimationTrigger.gisAnimationEnd)
        {
            return MonsterFSMCreator.MonsterIdleFSM(this);
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


    private MonsterFSMBase AttackFSMTransition()
    {
        float NewTime = Time.time;

        if (gAttackChecer.gIsPlayerChecker)
        {
            if (NewTime - gCurrentAttackDelay > gAttackDelay)
            {
                SoundManager.PlayVFXSound("1Stage_Macarong_Attack", transform.position);
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
        SoundManager.PlayVFXSound("1Stage_Macarong_Dead", transform.position);
    }

    protected override void HitSound()
    {
        SoundManager.PlayVFXSound("1Stage_Macarong_Hit", transform.position);

    }
}
