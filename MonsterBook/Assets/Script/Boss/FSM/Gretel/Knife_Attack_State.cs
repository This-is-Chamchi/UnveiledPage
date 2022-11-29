using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Animations.Rigging;

public class Knife_Attack_State : FSM_State<Gretel>
{
    static readonly Knife_Attack_State instance = new Knife_Attack_State();
    public static Knife_Attack_State Instance
    {
        get { return instance; }
    }


    private bool OnetimeTrigger = false;
    private int CutCount = 0;                   // 나이프 공격 횟수 Counter
    private bool AttackTimer = true;            // 공격 타이머 트리거
    private Transform PlayerTransform;          // 플레이어포지션
    private float Dist;
    private bool CutCountOneTimeTrigger;
    private Transform GretelTransform;
    private float Dist_NoJump;
    public override void EnterState(Gretel _Gretel)
    {
        CutCount = 0;
        _Gretel.m_AttackTimer = -1f;
        _Gretel._Ani.SetBool("KnifeAttackStart",true);
        _Gretel._Ani.SetBool("KnifeAttackEnd", false);
        GretelTransform = GameObject.FindWithTag("Gretel").transform;
        PlayerTransform = _Gretel.myTarget.transform;
        AttackTimer = true;

    }
    public override void UpdateState(Gretel _Gretel)
    {

        if(!_Gretel.GetComponent<Gretel>()._Ani.GetBool("GretelEnable"))
        {
            return;
        }


        if (AttackTimer == true)
        {
            _Gretel.m_AttackTimer += Time.deltaTime;   //어택타이머
        }
        if (_Gretel.m_AttackTimer <= _Gretel.KnifeFollowTime && _Gretel.m_AttackTimer > 0) 
        {
            if (_Gretel.ResetPosition == false)
            {
                if (_Gretel.GretelTransform.position.z >= 16.6)
                {
                    _Gretel.GretelTransform.position = new Vector3(GretelTransform.position.x, GretelTransform.position.y, GretelTransform.position.z - 0.05f);
                }
                if (_Gretel.GretelTransform.position.x <= -4.6)
                {
                    _Gretel.GretelTransform.position = new Vector3(GretelTransform.position.x + 0.05f, GretelTransform.position.y, GretelTransform.position.z);
                }
            }
            if (CutCount == _Gretel.KnifeAttackCount)
            {

                CutCount = 0;
                
                _Gretel.KnifeCollider.GetComponent<BoxCollider>().enabled = false;
                Debug.Log(_Gretel.Hansel.GetComponent<Hansel>().CurrentHP);
                Debug.Log(_Gretel.Hansel.GetComponent<Hansel>()._isStuned);

                if (_Gretel.Hansel.GetComponent<Hansel>().CurrentHP <= 0 && _Gretel.Hansel.GetComponent<Hansel>()._isStuned == true)
                {
                    _Gretel._Ani.SetTrigger("KnifetoIdle");
                    _Gretel.ChangeState(Protected_State.Instance);
                }
                else
                {
                    _Gretel._Ani.SetBool("KnifeAttackEnd", true);
                    _Gretel.ChangeState(Soup_Attack_State.Instance); 
                }

            }
            else
            {
                Dist_NoJump = Vector3.Distance(_Gretel.GetComponent<Gretel>().PlayerNoJumpPosition.transform.position, _Gretel.transform.position);
                Dist_NoJump = (Dist_NoJump-40)/10+0.4f; //플레이어와 그레텔의 거리 범위 40~50   계산법 (x - 40) = 0 ~ 10 -> x/10 => 0 ~ 1 (Blend)로 넣음
                _Gretel._Ani.SetFloat("Blend", Dist_NoJump);
                _Gretel.KnifeCollider.GetComponent<BoxCollider>().enabled = false;

                //나이프 추격
                _Gretel.Rigobject.GetComponent<Rig>().weight = 0.5f;
                Dist = Vector3.Distance(PlayerTransform.position, _Gretel.transform.position);
                CutCountOneTimeTrigger = false;
                OnetimeTrigger = false;
            }
        }

        else if (_Gretel.m_AttackTimer > _Gretel.KnifeFollowTime)   //나이프 공격
        {

            if (_Gretel.FollowTrigger)
            {
                _Gretel.KnifeCollider.GetComponent<BoxCollider>().enabled = true;
                LookTarget(_Gretel.playerAimPoint.transform, GretelTransform);
                _Gretel.Rigobject.GetComponent<Rig>().weight = 0f;
            }

            if (OnetimeTrigger == false)
            {
                _Gretel._Ani.SetBool("KnifeAttackRoop", true);
                //LookTarget_SP(_Gretel.playerAimPoint.transform,GretelTransform);
                OnetimeTrigger = true;
            }
            if (CutCountOneTimeTrigger == false)
            {
                CutCount++;
                CutCountOneTimeTrigger = true;
            }
            
        }
    }
    public override void ExitState(Gretel _Gretel)
    {
        _Gretel.ResetPosition = true;
        _Gretel._Ani.SetBool("KnifeAttackRoop", false);
        //_Gretel._Ani.SetBool("KnifeAttackEnd", false);
        _Gretel._Ani.SetBool("KnifeAttackStart", false);

    }
    void LookTarget(Transform Target, Transform _Gretel)
    {

        Vector3 dir = Target.position - _Gretel.transform.position;
            Vector3 dirXZ = new Vector3(dir.x, 0f, dir.z);

            if (dirXZ == Vector3.zero)
                return;

            _Gretel.transform.rotation = Quaternion.RotateTowards(_Gretel.transform.rotation, Quaternion.LookRotation(dirXZ), 100 * Time.deltaTime);
    }

    void LookTarget_SP(Transform Target, Transform _Gretel)
    {
        Vector3 dir = Target.position - _Gretel.transform.position;
        Vector3 dirXZ = new Vector3(dir.x, 0f, dir.z);

        if (dirXZ == Vector3.zero)
            return;

        _Gretel.transform.rotation = Quaternion.RotateTowards(_Gretel.transform.rotation, Quaternion.LookRotation(dirXZ), 500 * Time.deltaTime);
    }


}
