using System.Collections;
using System.Collections.Generic;
using MonsterFSM;
using UnityEngine;

public class MatcheFireBug : AttackMonster
{
    [SerializeField]
    private float TalkingSoundTime = 0.5f;
    private float CurrentSoundTime;
    protected override void Start()
    {
        base.Start();
        FSM = MonsterFSMCreator.MonsterIdleFSM(this);
        gCurrentAttackDelay = 0.0f;
        SoundManager.PlayVFXSound("2Stage_Bug_Summon" , transform.position);
    }
    protected override void Update()
    {
        base.Update();
        gCurrentAttackDelay += Time.deltaTime;
        CurrentSoundTime += Time.deltaTime;
        if (TalkingSoundTime < CurrentSoundTime)
        {
            SoundManager.PlayVFXSound("2Stage_Bug_Talking", transform.position);
            CurrentSoundTime = 0.0f;
        }

        if (gAttackChecer.gIsPlayerChecker && gCurrentAttackDelay > gAttackDelay)
        {
            gCurrentAttackDelay = 0.0f;
            gAttackChecer.PlayerOnDamage();
        }
        
    }

    


    protected override MonsterFSMBase Transition()
    {
        if (FSM is Monster_FollowPlayer)
        {            
            if (gAttackChecer.gIsPlayerChecker)
            {
                return MonsterFSMCreator.MonsterIdleFSM(this);
            }
        }
        else if (FSM is Monster_Idle)
        {
            if (gFindMonsterScript.gIsPlayerChecker && !gAttackChecer.gIsPlayerChecker)
            {
                return MonsterFSMCreator.MonsterFollowPlayerFSM(this);
            }
        }
        else if (FSM is Monster_Hit)
        {
            
        }
        return FSM;
    }

    protected override void DeadSound()
    {
        SoundManager.PlayVFXSound("2Stage_Bug_HIt", transform.position);
    }

    protected override void HitSound()
    {
        
    }
}
