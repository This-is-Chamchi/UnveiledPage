using UnityEngine;

public class DeadState : IState {
    private GameObject _Hansel;
    private GameObject _Gretel;
    private GameObject _Anna;

    public override void OnStateEnter(PlayerController player)  {
        player.rigid.velocity = Vector3.zero;
        player.ani.SetTrigger("Death");
        player.invinBool = true;
        player.input.SetInputAction(false);

        Game.UI.UIController.Instance.OpenPopup(new UIGameOverPopupData(){
        });
        
    }
    public override void OnStateExcute(PlayerController player) {

        return;
    }

    public override void OnStateExit(PlayerController player)   {
        return;
    }
}
