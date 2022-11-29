using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class AttackMonster : MonsterBase
{
    private float CurrentAttackDelay = float.MinValue;
    public float gCurrentAttackDelay {get {return CurrentAttackDelay;} set{CurrentAttackDelay = value;} }

    [SerializeField] private MonsterAttackChecker AttackChecer;
    [SerializeField] private FindActor FindMonsterScript;
    [SerializeField] private int AttackDamage;    
    [SerializeField] private float AttackDelay;    


    public int gAttackDamage { get { return AttackDamage; } protected set { AttackDamage = value; } }    
    public float gAttackDelay { get { return AttackDelay; } protected set { AttackDelay = value; } }    


    public FindActor gFindMonsterScript => FindMonsterScript;
    public MonsterAttackChecker gAttackChecer => AttackChecer;
}
