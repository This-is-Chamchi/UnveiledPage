
public class StateMachine <t>
{
    private t Owner;
    private FSM_State<t> m_CurrentState;
    private FSM_State<t> m_PreviousState;

    public void Awake()
    {
        m_CurrentState = null;
        m_PreviousState = null;
    }

    public void ChangeState(FSM_State<t> _NewState)
    {
        // same State = > return,
        if(_NewState == m_CurrentState)
        {
            return;
        }

        m_PreviousState = m_CurrentState;

        //already cul state is exist, then just call null,
        if (m_CurrentState != null)
        {
            m_CurrentState.ExitState(Owner);
        }
        m_CurrentState = _NewState;
        
        //Cur state is != null, then call state
        if (m_CurrentState != null)
        {
            m_CurrentState.EnterState(Owner);
        }
    }

    //Inital
    public void Initial_Setting(t _Owner, FSM_State<t> _InitialState)
    {
        Owner = _Owner;
        ChangeState(_InitialState);
    }

    public void Update()
    {
        if (m_CurrentState != null)
        {
            m_CurrentState.UpdateState(Owner);
        }
    }

    //이전상태
    public void StartRevert()
    {
        if (m_PreviousState != null)
        {
            ChangeState(m_PreviousState);
        }
    }

}
