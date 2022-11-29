using LDS;
using MonsterFSM;
using MonsterFSM.RollRollFSM;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

static public class MonsterFSMCreator
{
    static public MonsterFSMBase MonsterDeadFSM(MonsterBase Monster)
    {
        var Component = Monster.gameObject.GetComponent<Monster_Dead>();
        if (Component == null)
            Component = Monster.gameObject.AddComponent<Monster_Dead>();
        Component.Init(Monster);
        return Component;
    }
    static public MonsterFSMBase MonsterHitFSM(MonsterBase Monster)
    {
        var Component = Monster.gameObject.GetComponent<Monster_Hit>();
        if (Component == null)
            Component = Monster.gameObject.AddComponent<Monster_Hit>();
        Component.Init(Monster);
        return Component;
    }
    static public MonsterFSMBase MonsterPatrolFSM(MonsterBase Monster)
    {
        var Component = Monster.gameObject.GetComponent<Monster_Patrol>();
        if (Component == null)
            Component = Monster.gameObject.AddComponent<Monster_Patrol>();
        Component.Init(Monster);
        return Component;
    }
    static public MonsterFSMBase MonsterRunningFSM(MonsterBase Monster)
    {
        var Component = Monster.gameObject.GetComponent<Monster_Running>();
        if (Component == null)
            Component = Monster.gameObject.AddComponent<Monster_Running>();
        Component.Init(Monster);
        return Component;
    }
    static public MonsterFSMBase MonsterIdleFSM(MonsterBase Monster)
    {
        var Component = Monster.gameObject.GetComponent<Monster_Idle>();
        if (Component == null)
            Component = Monster.gameObject.AddComponent<Monster_Idle>();
        Component.Init(Monster);
        return Component;
    }

    static public MonsterFSMBase MonsterFlyIdleFSM(MonsterBase Monster)
    {
        var Component = Monster.gameObject.GetComponent<Monster_Flying>();
        if (Component == null)
            Component = Monster.gameObject.AddComponent<Monster_Flying>();
        Component.Init(Monster);
        return Component;
    }

    static public MonsterFSMBase MonsterFollowPlayerFSM(MonsterBase Monster)
    {
        var Component = Monster.gameObject.GetComponent<Monster_FollowPlayer>();
        if (Component == null)
            Component = Monster.gameObject.AddComponent<Monster_FollowPlayer>();
        Component.Init(Monster);
        return Component;
    }
    static public MonsterFSMBase MonsterNormalAttack(MonsterBase Monster)
    {
        var Component = Monster.gameObject.GetComponent<Monster_NormalAttack>();
        if (Component == null)
            Component = Monster.gameObject.AddComponent<Monster_NormalAttack>();
        Component.Init(Monster);
        return Component;
    }
    static public MonsterFSMBase MonsterJumpAttack(MonsterBase Monster)
    {
        var Component = Monster.gameObject.GetComponent<Monster_Jump>();
        if (Component == null)
            Component = Monster.gameObject.AddComponent<Monster_Jump>();
        Component.Init(Monster);
        return Component;
    }
    static public MonsterFSMBase MonsterFlyAttack(MonsterBase Monster)
    {
        var Component = Monster.gameObject.GetComponent<Monster_FlyingAttack>();
        if (Component == null)
            Component = Monster.gameObject.AddComponent<Monster_FlyingAttack>();
        Component.Init(Monster);
        return Component;
    }

}
