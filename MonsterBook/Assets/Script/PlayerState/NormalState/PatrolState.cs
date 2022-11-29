public class PatrolState : IState   {

    private int m_CountPointer = 0;

    public override void OnStateEnter(PlayerController player)  {
        player.input.SetInputAction(false);
        player.invinBool = true;
         m_CountPointer = 0;
    }     

    public override void OnStateExcute(PlayerController player) {
        if (m_CountPointer != player.playerPatrolLocaiton.Length)   {
                #region Movement to m_CountPointer

                var m_PlayerMovePos = new UnityEngine.Vector3(player.playerPatrolLocaiton[m_CountPointer].transform.position.x , player.transform.position.y , player.playerPatrolLocaiton[m_CountPointer].transform.position.z);
                player.transform.position = UnityEngine.Vector3.MoveTowards(
                player.transform.position, m_PlayerMovePos,
                player.walkSpeed/2 * UnityEngine.Time.fixedDeltaTime);
                player.ani.SetFloat("WalkSpeed", .5f);
                #endregion

                #region LookRotation

                var m_lookatVec = (new UnityEngine.Vector3(player.playerPatrolLocaiton[m_CountPointer].transform.position.x ,player.transform.position.y , player.playerPatrolLocaiton[m_CountPointer].transform.position.z));

                player.transform.LookAt(m_lookatVec);

                #endregion
                
                if (player.transform.position.x == player.playerPatrolLocaiton[m_CountPointer].transform.position.x)

                    m_CountPointer++;
                else    return;
        }
        else    {
            player.ani.SetFloat("WalkSpeed", 0.0f);
            player.ChangeState(PlayerState.IdleState);
        }
    }

    public override void OnStateExit(PlayerController player)   {
        player.invinBool = false;
    }
}
