public class AttackState : IState   {
    private float m_AttackdeltaTime = .0f;       //Attck Timer 
    private float m_AttackTimer = .0f;           //Set Timer

    public override void OnStateEnter(PlayerController player)  {
        
        m_AttackdeltaTime = .0f;
        player.ani.SetTrigger("Attack" + player.attackCount);
            switch (player.attackCount) {
                    case 1:
                        m_AttackTimer = player.OneHandAttack_1;
                        break;
                        
                    case 2:
                        m_AttackTimer = player.OneHandAttack_2;
                        break;

                    case 3:
                        m_AttackTimer = player.OneHandAttack_3;
                        break;
            }
    }

    public override void OnStateExcute(PlayerController player) {
        m_AttackdeltaTime += UnityEngine.Time.deltaTime;
        if(m_AttackdeltaTime >= m_AttackTimer)  { 

            m_AttackdeltaTime = 0.0f;
            player.ChangeState(PlayerState.WalkState);
        }    
    }

    public override void OnStateExit(PlayerController player)   {
        player.attackCount++;
        if (player.attackCount > 3) player.attackCount = 1;
               
        player.AttackBoxOff(0);
        player.Walk();
    }
}


