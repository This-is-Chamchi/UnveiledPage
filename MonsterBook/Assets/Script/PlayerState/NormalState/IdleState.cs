public class IdleState : IState {
    private float m_restTime = 0.0f;
    private bool m_restBool = false;

    public override void OnStateEnter(PlayerController player)  {
        m_restTime = 0.0f;
        m_restBool = true;
        player.ani.SetTrigger("Idle");
    }

    public override void OnStateExcute(PlayerController player) {

        if (player.walkVector != 0) {
            player.ani.ResetTrigger("Rest");
            player.ChangeState(PlayerState.WalkState);
        }
        else if (m_restBool)    {
            m_restTime += UnityEngine.Time.deltaTime;
            if (m_restTime > 1) {
                player.attackCount = 1;
                player.ani.SetTrigger("Rest");
                m_restTime = 0;
                m_restBool = false;
            }
        }
    }

    public override void OnStateExit(PlayerController player)   {
        return;
    }
}
