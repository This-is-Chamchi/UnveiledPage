using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Anna_Wait_State : FSM_State<Anna>
{
    static readonly Anna_Wait_State instance = new Anna_Wait_State();
    public static Anna_Wait_State Instance
    {
        get { return instance; }
    }


    public override void EnterState(Anna _Anna)
    {
        _Anna.Halo.GetComponent<Renderer>().sharedMaterial.SetFloat("_Mask_Dissolve_Control", -1);
        _Anna.Anna_Ani.SetTrigger("Anna_Start");
    }

    public override void ExitState(Anna _Anna)
    {
        
    }

    public override void UpdateState(Anna _Anna)
    {
        

    }


}
