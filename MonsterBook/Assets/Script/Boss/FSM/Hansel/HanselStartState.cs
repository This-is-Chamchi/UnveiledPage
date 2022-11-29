using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HanselStartState : FSM_State<Hansel>
{
    private bool Animation;
    public override void EnterState(Hansel _Hansel)
    {
        //eat 애니메이션 수정 필요
    }

    public override void ExitState(Hansel _Hansel)
    {
        
    }

    public override void UpdateState(Hansel _Hansel)
    {
        if(Animation == false)
        {
            _Hansel.ChangeState(HanselIdelState.Instance);
        }
    }


}
