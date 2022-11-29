using UnityEngine;

public class BellyAttack_State : FSM_State<Hansel>
{
    static readonly BellyAttack_State instance = new BellyAttack_State();

    public static BellyAttack_State Instance
    {
        get 
        {
            return instance; 
        } 
    }
    private float m_AttackTimer = 0f;
    private float m_AttackEndTimer = 0f;
    private bool onetimeAttack = false;

    public override void EnterState(Hansel _Hansel)
    {
        onetimeAttack = false;
        m_AttackTimer = 0;
        m_AttackEndTimer = 0;
        _Hansel.SmashCollider_L.SetActive(false);
        _Hansel.SmashCollider_R.SetActive(false);
        _Hansel.isBelly = true;
    }

    public override void UpdateState(Hansel _Hansel)
    {
        if (onetimeAttack == true)
        {
            if (_Hansel.myTarget && _Hansel.isBelly == true)
            {
                m_AttackTimer += Time.fixedDeltaTime;
                if (m_AttackTimer <= _Hansel.BellyAttackSpeed)
                {
                    _Hansel.rb.AddForce(_Hansel.transform.forward * _Hansel.BellyPower, ForceMode.Impulse);
                }
                else
                {
                    _Hansel.isBelly = false;
                    _Hansel.ChaseTime = 0.0f;
                }
            }
            else
            {
                m_AttackEndTimer += Time.fixedDeltaTime;
                if (m_AttackEndTimer >= _Hansel.BellyAttackSpeed + 1)
                {
                    m_AttackEndTimer = 0;
                    _Hansel.ChangeState(HanselMove_State.Instance);

                }
            }
        }
        else
        {

            if (_Hansel.myTarget == null && !_Hansel.isSmash)
            {
                return;
            }

            else if (onetimeAttack == false)
            {
                #region Damage Collider
                int m_Damage = _Hansel.Hansel_BellyDamage;
                _Hansel.BellyCollider.GetComponent<BellyCol>().g_Player_To_Damgage = m_Damage;
                _Hansel.BellyCollider.GetComponent<BellyCol>().g_Transform = _Hansel.transform;
                _Hansel.BellyCollider.GetComponent<BellyCol>().g_PlayerTransform = _Hansel.myTarget.transform;

                _Hansel.BellyCollider.GetComponent<BellyCol>().g_BellyForce = _Hansel.BellyForce;
                _Hansel.BellyCollider.GetComponent<BellyCol>().g_BellyForceUp = _Hansel.BellyForceUp;
                #endregion

                _Hansel.OnDircalculator(1);

                _Hansel.Ani.SetTrigger("H_BellyAttack");
                //_Hansel.BellyCollider.SetActive(true);


                _Hansel.SmashCollider_L.SetActive(false);
                _Hansel.SmashCollider_R.SetActive(false);
                onetimeAttack = true;
            }
        }

    }

    public override void ExitState(Hansel _Hansel)
    {
        _Hansel.isBelly = false;
        _Hansel.Ani.ResetTrigger("H_BellyAttack");
    }
}
