public class SpecialAttackState : IState {

    public override void OnStateEnter(PlayerController player)  {
        player.ui.SP_Cur -= 100;
        player.ui.SetSp(player.ui.SP_Cur);
        player.ui.SP_Using = true;
        player.invinBool = true;
        player.ani.SetTrigger("SAttack");
    }

    public override void OnStateExcute(PlayerController player) {

        if(player.ani.GetCurrentAnimatorStateInfo(0).IsName("Serros_SAttack") &&
        player.ani.GetCurrentAnimatorStateInfo(0).normalizedTime >= .95f)   {
            player.Walk();
            player.ChangeState(PlayerState.WalkState);
        }
    }

    public override void OnStateExit(PlayerController player)   {
        player.invinBool = false;
        player.ui.SP_Using = false;
        player.AttackBoxOff(3);
    }
}