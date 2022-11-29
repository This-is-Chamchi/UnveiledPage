using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Anna_Fly_State : FSM_State<Anna>
{
    static readonly Anna_Fly_State instance = new Anna_Fly_State();
    public static Anna_Fly_State Instance
    {
        get { return instance; }
    }

    private float time;


    public override void EnterState(Anna _Anna)
    {
        time = 0;
    }

    public override void ExitState(Anna _Anna)
    {
        
    }

    public override void UpdateState(Anna _Anna)
    {
        time += Time.deltaTime;

        _Anna.transform.position = new Vector3(_Anna.transform.position.x, _Anna.transform.position.y+_Anna.FlySpeed, _Anna.transform.position.z);

        if(_Anna.transform.position.y > _Anna.FlyPosition)
        {
            _Anna.Anna_Ani.SetTrigger("Anna_FlyEnd");
            _Anna.Halo.GetComponent<Renderer>().material.SetFloat("_Mask_Dissolve_Control",time);
            _Anna.GroundLanding = false;
        }
    }

    
}
