using System;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.ExceptionServices;
using Unity.VisualScripting;
using UnityEngine;

public class SmashAttack_State : FSM_State<Hansel>
{
    static readonly SmashAttack_State instance = new SmashAttack_State();
    public static SmashAttack_State Instance
    {
        get { return instance; }
    }
    private bool m_isAttack_1 = false;
    private bool m_isAttack_2 = false;
    private bool m_isAttack_3 = false;
    private bool m_isAttack_4 = false;
    static SmashAttack_State() { }
    private SmashAttack_State() { }


    public override void EnterState(Hansel _Hansel)
    {
        if (_Hansel.myTarget == null)
        {
            return;
        }
        _Hansel.SmashCollider_L.SetActive(false);
        _Hansel.SmashCollider_R.SetActive(false);
        _Hansel.isSmash = true;
        _Hansel.isRolling = false;
        _Hansel.isBelly = false;
        _Hansel.isRushing = false;
        m_isAttack_1 = false;
        m_isAttack_2 = false;
        m_isAttack_3 = false;
        m_isAttack_4 = false;

        #region Damage Collider
        int m_Damage = _Hansel.Hansel_SmashDamage;
        _Hansel.SmashCollider_R.GetComponent<SmashCol>().g_Player_To_Damgage = m_Damage;
        _Hansel.SmashCollider_R.GetComponent<SmashCol>().g_Transform = _Hansel.transform;


        _Hansel.SmashCollider_L.GetComponent<SmashCol>().g_Player_To_Damgage = m_Damage;
        _Hansel.SmashCollider_L.GetComponent<SmashCol>().g_Transform = _Hansel.transform;

        #endregion

        #region Random Checker
        if (_Hansel.isSmashRandomBool)
        {
            _Hansel.RandCalculateForSmash(7);
            _Hansel.isSmashRandomBool = false;
        }
        #endregion

        _Hansel.OnDircalculator(1);

        #region Pattern Checker
        switch (_Hansel.ForSmashP)
        {
            case 1:
                m_isAttack_1 = true;
                _Hansel.Ani.SetTrigger("H_SmashAttack");
                break;
            //Pattern 1 : 1

            case 2:
                m_isAttack_2 = true;
                _Hansel.Ani.SetTrigger("H_SmashAttack2");
                break;
            //Pattern 2 : 1 -> 2

            case 3:
                m_isAttack_3 = true;
                _Hansel.Ani.SetTrigger("H_SmashAttack3");
                break;
            //Pattern 3 : 2 -> 3

            case 4:
                m_isAttack_4 = true;
                _Hansel.Ani.SetTrigger("H_SmashAttack4");
                break;
            //Pattern 4 : 4
        }
        #endregion

    }

    public override void UpdateState(Hansel _Hansel)
    {


        if (_Hansel.myTarget && _Hansel.isSmash)
        {
            _Hansel.Attack_Time += Time.deltaTime;
            switch (_Hansel.ForSmashP)
            {
                case 1:
                    if (_Hansel.Attack_Time >= _Hansel.AttackPattern_1)
                    {
                        _Hansel.isSmashRandomBool = true;
                        m_isAttack_1 = false;             
                        m_isAttack_2 = false;
                        m_isAttack_3 = false;
                        m_isAttack_4 = false;
                        _Hansel.isSmash = false;
                        _Hansel.Attack_Time = 0;
                        return;
                    }

                    break;

                case 2:
 
                    if (_Hansel.Attack_Time >= _Hansel.AttackPattern_2)
                    {
                        _Hansel.isSmashRandomBool = true;
                        m_isAttack_1 = false;
                        m_isAttack_2 = false;
                        m_isAttack_3 = false;
                        m_isAttack_4 = false;
                        _Hansel.isSmash = false;
                        _Hansel.Attack_Time = 0;
                        return;
                    }
                    break;


                case 3:
                    if (_Hansel.Attack_Time >= _Hansel.AttackPattern_3)
                    {
                        _Hansel.isSmashRandomBool = true;
                        m_isAttack_1 = false;
                        m_isAttack_2 = false;
                        m_isAttack_3 = false;
                        m_isAttack_4 = false;
                        _Hansel.isSmash = false;
                        _Hansel.Attack_Time = 0;
                        return;
                    }
                    break;

                case 4:
                    if (_Hansel.Attack_Time >= _Hansel.AttackPattern_4)
                    {
                        _Hansel.isSmashRandomBool = true;
                        m_isAttack_1 = false;
                        m_isAttack_2 = false;
                        m_isAttack_3 = false;
                        m_isAttack_4 = false;
                        _Hansel.isSmash = false;
                        _Hansel.Attack_Time = 0;
                        return;
                    }
                    break;
                case 5:
                    if (true)  
                    {
                        _Hansel.ChangeState(RushAttack_State.Instance);
                    }
                    break;
                case 6:
                    if (true)
                    {
                        _Hansel.ChangeState(BellyAttack_State.Instance);
                    }
                    break;
                default:
                    Debug.LogError("caseOver" + _Hansel.ForSmashP);
                    break;

            }
            return;

        }
        else if ((!_Hansel.CheckRange() || !_Hansel.LookPlayer) && (!_Hansel.isSmash &&!m_isAttack_1 && !m_isAttack_2 && !m_isAttack_3 && !m_isAttack_4))
        {
            _Hansel.ChangeState(HanselMove_State.Instance);
        }
    }

    public override void ExitState(Hansel _Hansel)
    {
        _Hansel.isSmash = false;
        _Hansel.Attack_Time = 0;
        _Hansel.isSmashRandomBool = true;
        return;
    }

}
