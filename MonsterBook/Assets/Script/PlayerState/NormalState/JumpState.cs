public class JumpState : IState {
    public override void OnStateEnter(PlayerController player)  {
        player.Walk();
        player.checkJump = true;
        player.ani.SetTrigger("Jump");
    }

    public override void OnStateExcute(PlayerController player) {
        if (player.checkJump && player.isGround)
            player.ChangeState(PlayerState.WalkState);
        else    {
            player.ani.SetTrigger("ResetAct");
            player.ChangeState(PlayerState.WalkState);
        }
        player.Walk();
    }

    public override void OnStateExit(PlayerController player)   {
        player.isJump -= 1;
        player.checkJump = false;
    }
}
