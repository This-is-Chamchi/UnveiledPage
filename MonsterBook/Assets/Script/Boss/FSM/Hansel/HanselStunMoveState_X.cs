using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HanselStunMoveState_X : FSM_State<Hansel>
{
    private Vector3 m_OldPosition;
    private Vector3 m_CurrentPosition;
    private float m_SpeedBoi = 0;

    static readonly HanselStunMoveState_X instance = new HanselStunMoveState_X();
    public static HanselStunMoveState_X Instance { get { return instance; } }

    public override void EnterState(Hansel _Hansel)
    {
        _Hansel.Isinvincibility = true;
        _Hansel.Ani.Play("H_Walk");
        _Hansel.SmashCollider_L.SetActive(false);
        _Hansel.SmashCollider_R.SetActive(false);
        _Hansel.rb.velocity = Vector3.zero;
        m_OldPosition = _Hansel.transform.position;
        m_SpeedBoi = 0;
    }

    public override void ExitState(Hansel _Hansel)
    {
        _Hansel.Ani.SetFloat("H_Walk", 0);
    }

    public override void UpdateState(Hansel _Hansel)
    {
        if (!_Hansel.isSmash && !_Hansel.isBelly &&!_Hansel.isRolling &&!_Hansel.isRushing )
        {
            #region Lookat

            var m_lookatVec = (new Vector3(_Hansel.RuntoGretelPosition_X.transform.position.x, 0, 0)
                - new Vector3(_Hansel.transform.position.x, 0, 0)).normalized;

            _Hansel.transform.rotation = Quaternion.Lerp(_Hansel.transform.rotation,
                Quaternion.LookRotation(m_lookatVec), Time.fixedDeltaTime * _Hansel.Hansel_RotSpeed);

            #endregion

            #region Movement
            var m_Dir = new Vector3(_Hansel.RuntoGretelPosition_X.transform.position.x - _Hansel.transform.position.x, 0, _Hansel.RuntoGretelPosition_X.transform.position.z - _Hansel.transform.position.z).normalized;

            var m_fMaxSpeed = _Hansel.Hansel_Speed;
            var m_currentSpeed = m_fMaxSpeed;
            var Multiple = m_Dir * (m_currentSpeed) * Time.fixedDeltaTime;
            _Hansel.rb.MovePosition(_Hansel.transform.position + Multiple);
            #endregion

            #region velocity cul
            m_CurrentPosition = _Hansel.transform.position;
            var dis = m_CurrentPosition - m_OldPosition;
            var distance = Mathf.Sqrt(Mathf.Pow(dis.x, 2) + 0 + Mathf.Pow(dis.z, 2));
            var velocity = distance / Time.deltaTime;
            m_OldPosition = m_CurrentPosition;

            var m_Val = velocity / velocity;

            m_SpeedBoi = Mathf.SmoothDamp(m_SpeedBoi, 1.0f, ref m_Val, 0.1f, m_fMaxSpeed, Time.fixedDeltaTime);

            m_SpeedBoi = 1.0f;
            if (m_SpeedBoi > 1.0f)
            {
                m_SpeedBoi = 1.0f;
            }

            _Hansel.Ani.SetFloat("H_Walk", m_SpeedBoi);
            #endregion

            if (((int)_Hansel.RuntoGretelPosition_X.transform.position.x == (int)_Hansel.transform.position.x) && (!_Hansel.isRushing && !_Hansel._isStuned && !_Hansel.isBelly &&
                  !_Hansel.isSmash))
            {
                _Hansel.StunMove = true;
                _Hansel.ChangeState(Stun_State.Instance);
            }
        }

    }



}