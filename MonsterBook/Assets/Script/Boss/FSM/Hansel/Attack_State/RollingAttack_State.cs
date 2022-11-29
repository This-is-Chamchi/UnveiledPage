using UnityEngine;

public class RollingAttack_State : FSM_State<Hansel>
{
    static readonly RollingAttack_State instance = new RollingAttack_State();

    public static RollingAttack_State Instance
    {
        get { return instance; }
    }

    private float m_WaitForFood = 0;
    private float m_WaitEnd= 0;
    private int m_CountPointer = 0;

    static RollingAttack_State() { }
    private RollingAttack_State() { }
 

    public override void EnterState(Hansel _Hansel)
    {
        //타겟 확인(플레이어)
        if (_Hansel.myTarget == null)
        {
            return;
        }
        m_CountPointer = 0;
        m_WaitForFood = 0;
        m_WaitEnd = 0;
        _Hansel.rb.velocity = Vector3.zero;

        #region Damage Collider
        int m_Damage = _Hansel.Hansel_RollingDamage;
        _Hansel.RollingCollider.GetComponent<RollingCol>().g_Player_To_Damgage = m_Damage;
        _Hansel.RollingCollider.GetComponent<RollingCol>().g_Transform = _Hansel.transform;
        #endregion
        
        _Hansel.OnDircalculator(1);
        _Hansel.SmashCollider_L.SetActive(false);
        _Hansel.SmashCollider_R.SetActive(false);
        _Hansel.CapCol_Hansel.isTrigger = true;
        _Hansel.Isinvincibility = true;
        _Hansel.Ani.SetTrigger("H_RollingAttackR");
        _Hansel.Ani.SetBool("H_RollingAttack", true);
        _Hansel.isRolling = true;
        _Hansel.isBelly = false;
        _Hansel.isSmash = false;
        _Hansel.isRolling = false;
    }

    public override void UpdateState(Hansel _Hansel)
    {

        m_WaitForFood += Time.fixedDeltaTime;
        if (m_WaitForFood >= _Hansel.RollingWaitTime)
        {
            if (m_CountPointer != _Hansel.Rolling_Position.Length)
            {
                _Hansel.RollingCollider.SetActive(true);

                #region Movement to m_CountPointer
                _Hansel.transform.position = Vector3.MoveTowards(
        _Hansel.transform.position, _Hansel.Rolling_Position[m_CountPointer].transform.position,
         _Hansel.RollingSpeed * Time.fixedDeltaTime);
                #endregion

                #region LookRotation

                var m_lookatVec = (new Vector3(_Hansel.Rolling_Position[m_CountPointer].transform.position.x, 0, 0)).normalized;

                _Hansel.transform.rotation = Quaternion.Lerp(_Hansel.transform.rotation,
                    Quaternion.LookRotation(m_lookatVec), Time.fixedDeltaTime * _Hansel.RollingRotation);
                #endregion

                if (_Hansel.transform.position == _Hansel.Rolling_Position[m_CountPointer].transform.position) //&& _Hansel.Col_with_Wall
                {
                    _Hansel.OnDircalculator(1);
                    _Hansel.HanselSound("1StageHansel_Rolling");
                    m_CountPointer++;
                 
                }
                else
                    return;

            }

            else if(m_CountPointer == _Hansel.Rolling_Position.Length)
            {
                _Hansel.Ani.SetBool("H_RollingAttack", false);
                _Hansel.Isinvincibility = false;
                m_WaitEnd += Time.fixedDeltaTime;
                _Hansel.isRolling = false;
                if (m_WaitEnd >= 4)         //구르기 이후에 4초 대기;
                {                  
                    m_WaitEnd = 0;
                    _Hansel.ChangeState(HanselMove_State.Instance);   
                }
            }
        }

    }

    public override void ExitState(Hansel _Hansel)
    {
        _Hansel.Isinvincibility = false;
        _Hansel.CapCol_Hansel.isTrigger = false;
        _Hansel.isRolling= false;
        _Hansel.Ani.SetBool("H_RollingAttack", false);
        _Hansel.RollingCollider.SetActive(false);
        return;
    }
}
