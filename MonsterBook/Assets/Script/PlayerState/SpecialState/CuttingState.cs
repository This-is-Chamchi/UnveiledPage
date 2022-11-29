public class CuttingState : IState  {
    private float  m_CuttingWaitTIme = 0.0f;

    public override void OnStateEnter(PlayerController player)  {
        player.ani.SetTrigger("CutAttack");
    }

    public override void OnStateExcute(PlayerController player) {
        m_CuttingWaitTIme += UnityEngine.Time.deltaTime;
        if(m_CuttingWaitTIme >= 1.0f)
        {
            m_CuttingWaitTIme = 0;
            player.ChangeState(PlayerState.IdleState);
        }
    }

    public override void OnStateExit(PlayerController player)   {
        return;
    }
}
