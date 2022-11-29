
using UnityEngine;

public class DashState : IState
{
    string aniName;

    protected float Dash_RunningTime = 0.0f;

    public override void OnStateEnter(PlayerController player)  {
        //Player Can Dash with Jump.
        player.rigid.velocity = UnityEngine.Vector3.zero;
        player.invinBool = true;
  
        player.ani.SetTrigger("Dash");
        gameObject.layer = LayerMask.NameToLayer("PlayerDash");        
    }


    public override void OnStateExcute(PlayerController player) {    
        Dash_RunningTime += Time.fixedDeltaTime;
        if (Dash_RunningTime >= player.dashRunningTime) {
            player.invinBool = false;
            Dash_RunningTime = 0;         
            player.ChangeState(PlayerState.WalkState);
            player.Walk();
        }
    }

    public override void OnStateExit(PlayerController player)   {   
        gameObject.layer = LayerMask.NameToLayer("Player");
        return;
    }
}
