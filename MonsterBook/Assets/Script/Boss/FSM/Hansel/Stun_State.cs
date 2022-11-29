using UnityEngine;

public class Stun_State : FSM_State<Hansel>   //스턴상태 -> 다시 복귀
{
    static readonly Stun_State instance = new Stun_State();
    private Vector3 m_OldPosition;
    private Vector3 m_CurrentPosition;
    private float m_SpeedBoi = 0;

    public static Stun_State Instance
    {
        get { return instance; }
    }

    private float m_StunTimer = 0;
    private bool oneTime = false;
    private bool animationonetime = false;

    public override void EnterState(Hansel _Hansel)
    {
        //타겟 확인(플레이어)
        if (_Hansel.myTarget == null)
        {
            return;
        }
        oneTime = false;
        _Hansel.Isinvincibility = true;
        _Hansel._isStuned = true;
        animationonetime = false;
        _Hansel.rb.velocity = Vector3.zero;
        m_OldPosition = _Hansel.transform.position;
        m_SpeedBoi = 0;
        Debug.Log("Hansel stuned... ");

        _Hansel.BellyCollider.SetActive(false);   //특수모션중 hp가 0이 되면 끄기전에 스턴상태가 됨
        _Hansel.RushCollider.SetActive(false);  // 대미지 콜라이더가 켜져있다면 꺼주는 기능
        _Hansel.RollingCollider.SetActive(false);
        _Hansel.SmashCollider_L.SetActive(false);
        _Hansel.SmashCollider_R.SetActive(false);


        m_StunTimer = 0;
        Debug.Log("Hansel stuned... ");
        _Hansel.CurrentHP = 0;
        _Hansel.Ani.SetTrigger("H_Cry");
        Debug.Log(_Hansel.PhaseChecker);

    }

    public override void UpdateState(Hansel _Hansel)
    {
        _Hansel.BellyCollider.SetActive(false);
        _Hansel.SmashCollider_L.SetActive(false);
        _Hansel.SmashCollider_R.SetActive(false);
        _Hansel.Attack3_Damagecol.SetActive(false);
        //Debug.Log("스턴중" + _Hansel.CurrentHP + _Hansel.PhaseChecker);


        if (_Hansel.CurrentHP >= 80 &&_Hansel.PhaseChecker == 1)
        {
            var time = Time.deltaTime;
            if (time > 0.2f && animationonetime == false)
            {
                _Hansel.Ani.SetFloat("H_Walk", 0);
                animationonetime = true;
            }
            if (time > 1.0f)
            {
                _Hansel.ChangeState(HanselStunMoveState_return.Instance);
                Debug.Log("스턴Move");
            }
        }
        if (_Hansel.CurrentHP >= 80 &&_Hansel.PhaseChecker == 2)
        {
             _Hansel.StunMove = true;
             _Hansel.ChangeState(HanselStunMoveState_return.Instance);
        }
    }

    public override void ExitState(Hansel _Hansel)
    {
        Debug.Log("stun상태 종료");
        _Hansel.Isinvincibility = false;
        _Hansel._isStuned = false;
        _Hansel._isStuned = false;
        _Hansel.StunMove = false;
        return;
    }
}
