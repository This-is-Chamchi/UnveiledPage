using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HanselIdelState : FSM_State<Hansel>
{
    static readonly HanselIdelState instance = new HanselIdelState();
    private bool onetime = false;
    public static HanselIdelState Instance
    {
        get { return instance; }
    }
    public override void EnterState(Hansel _Hansel)
    {
        _Hansel.HanselIdleTime_Cur = -999f;
        onetime = false;
    }

    public override void ExitState(Hansel _Hansel)
    {
    }

    public override void UpdateState(Hansel _Hansel)
    {
        if(_Hansel.HanselFSMStart == true && onetime == false)
        {
            _Hansel.HanselIdleTime_Cur = 0f;
            onetime = true;
        }
        _Hansel.HanselIdleTime_Cur += Time.deltaTime;

        if (_Hansel.HanselIdleTime_Cur > _Hansel.HanselIdleTime)
        {
            _Hansel.ChangeState(HanselMove_State.Instance);
            _Hansel.BossUI.SetActive(true);
        }

    }


}
