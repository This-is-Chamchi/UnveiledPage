using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Idle_State : FSM_State<Anna>
{
    static readonly Idle_State instance = new Idle_State();
    public static Idle_State Instance
    {
        get { return instance; }
    }
    public override void EnterState(Anna _Anna)
    {
        _Anna.Anna_IdleTime_Cur = 0f;
        _Anna.HitMotionAble = true;
    }

    public override void ExitState(Anna _Anna)
    {
        _Anna.HitMotionAble = false;
    }

    public override void UpdateState(Anna _Anna)
    {
        _Anna.Anna_IdleTime_Cur += Time.deltaTime;

        if (_Anna.Anna_IdleTime_Cur > _Anna.Anna_IdleTime)
        {
            _Anna.ChangeState_Move();
        }


    }

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {

    }
}
