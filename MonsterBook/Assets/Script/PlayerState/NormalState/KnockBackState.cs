public class KnockBackState : IState    {
    float m_time;

    public override void OnStateEnter(PlayerController player)  {        
        player.invinBool = true;        
        player.input.SetInputAction(false);
    }

    public override void OnStateExcute(PlayerController player) {
        m_time += UnityEngine.Time.deltaTime;
        if (player.isGround && m_time > 0.5f)   {
            m_time = 0;
            player.ChangeState(PlayerState.IdleState);
        }
    }

    public override void OnStateExit(PlayerController player)   {
        player.invinBool = false;
        player.input.SetInputAction(true);
    }
}
