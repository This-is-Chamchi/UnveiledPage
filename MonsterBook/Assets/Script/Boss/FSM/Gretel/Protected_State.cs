using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Animations.Rigging;

public class Protected_State : FSM_State<Gretel>
{
    static readonly Protected_State instance = new Protected_State();
    public static Protected_State Instance
    {
        get { return instance; }
    }

    private float m_AttackTimer;
    private bool onetime = false;
    private bool onetimeSound = false;
    // Start is called before the first frame update
    void Start()
    {
    }


    public override void EnterState(Gretel _Gretel)
    {
        _Gretel.Hansel.GetComponent<Hansel>().BossUI.GetComponent<UI_Boss_1Stage>().ChangePhase(true);
        _Gretel._Ani.SetBool("SoupAttackStart", false);
        _Gretel._Ani.SetBool("KnifeAttackStart", false);
        _Gretel._Ani.SetBool("ProtectedStart", true);   //애니메이션 재생
        _Gretel._Ani.SetBool("ProtectedEnd", false);
        _Gretel.Hansel.GetComponent<Hansel>().GretelColOn();
        _Gretel.Rigobject.GetComponent<Rig>().weight = 0;
        onetime = false;
        m_AttackTimer = 0;
    }

    public override void UpdateState(Gretel _Gretel)
    {
        if(_Gretel.KnifeAnimation == true)
        {
            return;
        }
        m_AttackTimer += Time.deltaTime;
        //_Gretel.transform.position = new Vector3(Vector3.MoveTowards(_Gretel.transform.position, _Gretel.Hansel.transform.position, 100 * Time.deltaTime).x,_Gretel.transform.position.y, _Gretel.transform.position.z);
        
        LookTarget(_Gretel.Hansel.transform, _Gretel.GretelTransform);
        if (m_AttackTimer > _Gretel.ProtectedTime) 
        {
            _Gretel._Ani.SetBool("ProtectedEnd", true);  //Protected 지속시간 종료시 종료 애니메이션
            _Gretel._Ani.SetBool("ProtectedStart", false);
            //_Gretel.Hansel.GetComponent<Hansel>().ResetState_2();
            _Gretel.ChangeState(Knife_Attack_State.Instance);
            m_AttackTimer = 0;
        }

        if(_Gretel.CurrentHP <= 0)
        {
            if(onetime == false)
            {
                _Gretel._Ani.Play("Death_New");
                onetime = true;
            }
            //_Gretel.gameObject.SetActive(false);
            if (onetimeSound == false)
            {
                _Gretel.Hansel.GetComponent<Hansel>().HanselSound("1StageHansel_Dead");
                onetimeSound = true;
            }
            
            _Gretel.Hansel.gameObject.SetActive(false);
            //게임 종료
        }

    }

    public override void ExitState(Gretel _Gretel)
    {
        _Gretel.Hansel.GetComponent<Hansel>().GretelColOff();
        _Gretel._Ani.SetBool("DamageTime", false);
        _Gretel._Ani.SetBool("KnifeAttackStart", true);

    }

    void LookTarget(Transform Target, Transform _Gretel)
    {

        Vector3 dir = Target.position - _Gretel.transform.position;
        Vector3 dirXZ = new Vector3(dir.x, 0f, dir.z);

        if (dirXZ == Vector3.zero)
            return;

        _Gretel.transform.rotation = Quaternion.RotateTowards(_Gretel.transform.rotation, Quaternion.LookRotation(dirXZ), 50 * Time.deltaTime);
    }

}
