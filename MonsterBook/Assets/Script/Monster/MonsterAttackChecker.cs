using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using MonsterFSM;

public class MonsterAttackChecker : MonoBehaviour
{


    
    
    private bool MonsterFollow;    
    private AttackMonster Monster;
    private IEntity PlayerEntity;
    private bool IsPlayerChecker = false;
    private Vector3 TargetPos;    


    public bool gIsPlayerChecker => IsPlayerChecker;
    public Vector3 gTargetPos => TargetPos;    

    private void Start()
    {
        if (Monster == null)
            Monster = GetComponentInParent<AttackMonster>();
    }


    private void OnTriggerStay(Collider other)
    {
        if (other.CompareTag("Player"))
        {

            
            if (PlayerEntity == null)
            {
                PlayerEntity = other.GetComponent<IEntity>();
            }
            TargetPos = other.transform.position;            
            IsPlayerChecker = true;
        }        
    }    

    private void OnTriggerExit(Collider other)
    {
        IsPlayerChecker = false;
    }
    private void Update()
    {
        bool MonsterAttackFSM = Monster.gFSM is MonsterFSMAttack;
        
        if (MonsterAttackFSM)
        {            
            if (Monster.gAnimationTrigger.gisEvent && IsPlayerChecker)            
                PlayerEntity.OnDamage(Monster.gAttackDamage, Monster.transform.position);            
        }
    }


    public void PlayerOnDamage()
    {
        if (PlayerEntity != null)
        {
            PlayerEntity.OnDamage(Monster.gAttackDamage, Monster.transform.position);
        }
    }



    //public void SelfDestruct()
    //{
    //    Debug.Log(PlayerEntity);
    //    if (PlayerEntity != null)
    //    {
    //        PlayerEntity.OnDamage(Monster.gAttackDamage , Monster.transform.position);
    //        Destroy(Monster.gameObject);
    //    }
    //}

}


