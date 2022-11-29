using UnityEngine;

public class ThrowPlayer_State : FSM_State<Hansel>
{
    static readonly ThrowPlayer_State instance = new ThrowPlayer_State();
    public static ThrowPlayer_State Instance { get { return instance; } }

    private float m_WaitTime = 0;
    private float m_WaitTime_ThrowPlayer = 3;

    static ThrowPlayer_State() { }
    private ThrowPlayer_State() { }

    public override void EnterState(Hansel _Hansel)
    {
        //타겟 확인(플레이어)
        if (_Hansel.myTarget == null)
        {
            return;
        }

        #region Damage Collider
        int m_Damage = _Hansel.Hansel_ThrowPlayer;
        _Hansel.SmashCollider_R.GetComponent<SmashCol>().g_Player_To_Damgage = m_Damage;
        _Hansel.SmashCollider_R.GetComponent<SmashCol>().g_Transform = _Hansel.transform;

        _Hansel.SmashCollider_L.GetComponent<SmashCol>().g_Player_To_Damgage = m_Damage;
        _Hansel.SmashCollider_L.GetComponent<SmashCol>().g_Transform = _Hansel.transform;

        #endregion
        
        m_WaitTime = 0;
        _Hansel.isTP = true;
        _Hansel.Ani.SetTrigger("H_ThrowPlayer");
        _Hansel.isRolling = false;
        _Hansel.isBelly = false;
        _Hansel.isRushing = false;
        _Hansel.myTarget.GetComponent<CapsuleCollider>().isTrigger = true;
        _Hansel.myTarget.GetComponent<PlayerController>().SetThrowState(true);
        _Hansel.SmashCollider_L.SetActive(false);
        _Hansel.SmashCollider_R.SetActive(false);
        //회전값 저장
        _Hansel.m_MyTartgetRot = _Hansel.myTarget.transform.rotation;


    }

    public override void UpdateState(Hansel _Hansel)
    {

        m_WaitTime += Time.fixedDeltaTime;

        if (m_WaitTime >= m_WaitTime_ThrowPlayer)          
        {
            m_WaitTime = 0;
            Debug.Log("던지기 State 종료- -> MoveState");
            _Hansel.ChangeState(HanselMove_State.Instance);
        } 

    }

    public override void ExitState(Hansel _Hansel)
    {
        _Hansel.myTarget.transform.rotation = _Hansel.m_MyTartgetRot;
        _Hansel.myTarget.transform.position = new Vector3(_Hansel.myTarget.transform.position.x, _Hansel.myTarget.transform.position.y, 0);
        Debug.LogError("던지기 상태 종료");
        _Hansel.isTP = false;
    }

}
