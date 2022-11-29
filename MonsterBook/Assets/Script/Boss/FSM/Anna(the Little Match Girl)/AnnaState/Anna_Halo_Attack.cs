using System.Collections;
using System.Collections.Generic;
using UnityEngine.Events;
using UnityEngine;

public class Anna_Halo_Attack : FSM_State<Anna>
{
    private int CurHaloCount;
    private float timer;
    private bool AttackEnd;
    static readonly Anna_Halo_Attack instance = new Anna_Halo_Attack();
    public static Anna_Halo_Attack Instance
    {
        get { return instance; }
    }

    public override void EnterState(Anna _Anna)
    {
        timer = -1.5f;
        CurHaloCount = 0;
        AttackEnd = false;
        _Anna.Anna_Ani.SetTrigger("Attack02_Start");
    }

    public override void ExitState(Anna _Anna)
    {
        
    }

    public override void UpdateState(Anna _Anna)
    {
        
        if (CurHaloCount >= _Anna.HaloCount)
        {
            AttackEnd = true;
            timer += Time.deltaTime;

            if(timer > 1.5f)
            {
                _Anna.Anna_Ani.SetTrigger("Attack02_End");
                _Anna.ChangeState_Idle();
            }
            
        }
        else
        {
            timer += Time.deltaTime;
        }


        if (timer > 0.5f && AttackEnd == false)
        {
            _Anna.AnnaSound("2StageAnna_MatchSummon");

            for (int i = 0; i < 8; i++)
            {
                _Anna.MatchObjectPool.GetComponent<Match_Object_Pool>().RespownHaloMatch(_Anna.HaloSpawnPoint[i].transform.position,i);
            }
            timer = 0f;
            CurHaloCount++;
            
        }
    }

}
