public class JumpAttackState : IState    {

     public override void OnStateEnter(PlayerController player) {
        player.ani.Play("JumpAttack");
        player.CheckJumpAttack = true;
        player.attackWeapon[0].GetComponent<Weapon>().isCutting = true;
        player.attackCount = 1;

     }

    public override void OnStateExcute(PlayerController player) {
        if(player.isGround) {
            player.ani.SetTrigger("jumpAttackReset");
             player.ChangeState(PlayerState.WalkState);
        }

        player.Walk();

    }

    public override void OnStateExit(PlayerController player)   {
        player.CheckJumpAttack = false;;
        player.attackWeapon[0].GetComponent<Weapon>().isCutting = false;
        return;
    }
}