using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Anna_Match_Attack : FSM_State<Anna>
{
    private float timer;
    private int CurMatchCount;
    private bool AttackEnd;
    // Start is called before the first frame update
    static readonly Anna_Match_Attack instance = new Anna_Match_Attack();
    public static Anna_Match_Attack Instance
    {
        get { return instance; }
    }

    public override void EnterState(Anna _Anna)
    {
        timer = 0f;
        CurMatchCount = 0;
        AttackEnd = false;
        _Anna.Anna_Ani.SetTrigger("Attack01_Start");
    }

    public override void ExitState(Anna _Anna)
    {
       
    }

    public override void UpdateState(Anna _Anna)
    {


        if (CurMatchCount == _Anna.MatchCount)
        {
            _Anna.Anna_Ani.SetTrigger("Attack01_End");  //공격 종료 애니메이션 시작
            CurMatchCount++;                            //카운트를 올리는것으로 setTrigger가 여러번 호출되는것을 방지
        }
        else
        {
            timer += Time.deltaTime;
        }

        if(timer > 0.7f)
        {
            if (_Anna.AnnaPhase == 1)
            {
                _Anna.AnnaSound("2StageAnna_MatchSummon");
                _Anna.MatchObjectPool.GetComponent<Match_Object_Pool>().RespownMatch(_Anna.MatchSpawnPoint.transform.position);
            }

            else
            {
                _Anna.AnnaSound("2StageAnna_MatchSummon");
                _Anna.MatchObjectPool.GetComponent<Match_Object_Pool>().RespownMatch_2(_Anna.MatchSpawnPoint.transform.position);
            }
            timer = 0;
            CurMatchCount++;
        }
    }

    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
