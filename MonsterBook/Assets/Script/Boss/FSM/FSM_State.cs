
abstract public class FSM_State<t>
{
    abstract public void EnterState(t _T);
    abstract public void UpdateState(t _T);
    abstract public void ExitState(t _T);
}
