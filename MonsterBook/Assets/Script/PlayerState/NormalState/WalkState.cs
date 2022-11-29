public class WalkState : IState
{   
    float m_AttackCountReset = 0.0f;
    public override void OnStateEnter(PlayerController player)  {   
        player.AttackBoxOff(0);
        player.AttackBoxOff(1);
        player.AttackBoxOff(2);
        m_AttackCountReset = 0.0f;
    }

    public override void OnStateExcute(PlayerController player) {      
        m_AttackCountReset += UnityEngine.Time.deltaTime;
        if (m_AttackCountReset >= 2.0f) {
            player.attackCount = 1;
            player.ChangeState(PlayerState.IdleState);
            m_AttackCountReset = 0.0f;
        }    
        player.Walk();
    }

    public override void OnStateExit(PlayerController player)   {
        return;      
    }
}
