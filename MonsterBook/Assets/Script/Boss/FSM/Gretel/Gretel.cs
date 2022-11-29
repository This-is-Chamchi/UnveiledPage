using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class Gretel : MonoBehaviour, IEntity
{
    #region   Gretel Stat var
    [Header("Stat")]
    public float GretelHP = 100;            //최대체력   
    public float CurrentHP;                 //현제체력
    public StateMachine<Gretel> state = null;
    private bool isDead = false;            //사망여부(아직 사용 x)
    [HideInInspector] public Animator _Ani;
    public GameObject CenterLook;
    public GameObject LeftLook;
    #endregion

    #region  KnifeAttack var
    [Header("KnifeAttack")]
    public float KnifeFollowTime;           //나이프 추격 시간
    public float KnifeAttackCount;          //나이프 공격횟수
    public float m_AttackTimer = 0f;
    public GameObject playerAimPoint;
    public GameObject KnifeCollider;
    public GameObject PlayerNoJumpPosition;
    public GameObject KnifeObject;
    public GameObject KnifeEffect1;
    public GameObject KnifeEffect2;
    public GameObject KnifeEffect3;
    public GameObject KnifeEffectPosition;
    [HideInInspector] public bool ResetPosition = false;
    public bool KnifeAnimation;
    #endregion

    #region  SoupAttack var
    [Header("SoupAttack")]
    public Transform SoupRangePoint1;       //스프 공격 범위 MIN
    public Transform SoupRangePoint2;       //스프 공격 범위 MAX
    public int SoupMin = 3;                 //스프 낙하 갯수 MIN
    public int SoupMax = 4;                 //스프 낙하 갯수 MAX
    public GameObject SoupObjectPool;       //스프 오브젝터 풀
    public float SoupResponseTime = 1.2f;   //스프 공격 간격
    public float SoupDeleteTime = 2.0f;     //스프 삭제 시간
    public float SolidProbability;          //건더기 스프 생성 여부
    public bool AttackTimerTrigger = false;
    public bool RotateTrigger = false;
    public bool FollowTrigger = false;
    #endregion

    #region  ProtectedAttack var
    public float ProtectedTime;
    public GameObject Rigobject;
    #endregion

    public Transform GretelTransform;
    [HideInInspector] public GameObject myTarget;
    [HideInInspector] public GameObject Hansel;
    [SerializeField] private UnityEvent endEvent;
    [SerializeField] private UnityEvent<bool> ChangeHPBar;
    public Transform GretelSoundPoint;



    // Start is called before the first frame update
    void Start()
    {
        _Ani = GetComponent<Animator>();
        Hansel = GameObject.FindWithTag("Boss");
        myTarget = GameObject.FindWithTag("Player");
        CurrentHP = GretelHP;
        state = new StateMachine<Gretel>();
        state.Initial_Setting(this, Knife_Attack_State.Instance);
    }

    // Update is called once per frame
    void Update()
    {
        state.Update();

        if(Input.GetKeyDown(KeyCode.T))
        {
            _Ani.Play("Death");
        }

    }


    public void DeathEvent()
    {
        endEvent.Invoke();
    }

    public void ChangeState(FSM_State<Gretel> _State)
    {
        state.ChangeState(_State);
    }

    public void GretelSound(string name)
    {
        SoundManager.PlayVFXSound(name, GretelSoundPoint.position);
    }

    public void GretelKnifeSound(string name)
    {
        SoundManager.PlayVFXSound(name, KnifeObject.transform.position);
    }

    public void OnDamage(int PlayerDamage, Vector3 pos)
    {
        CurrentHP -= PlayerDamage;
    }

    public void OnRecovery(int heal)
    {
        throw new System.NotImplementedException();
    }
    void AttackTimerReset()
    { 
        _Ani.SetBool("KnifeAttackRoop", false);
        m_AttackTimer = 0.0f;
    }

    void SoupAttackTimerStart()
    {
        m_AttackTimer = 0.0f;
        AttackTimerTrigger = true;
    }

    void StateChange_to_Animation(string state)
    {
        if (name == "Knife")
        {
            ChangeState(Knife_Attack_State.Instance);
        }
        else if (name == "Soup")
        {
            ChangeState(Soup_Attack_State.Instance);
        }
        else if (name == "Protect")
        {
            ChangeState(Protected_State.Instance);
        }
    }

    void RotateTriggerOn()
    {
        RotateTrigger = true;
    }

    void DamageTime(int onoff)
    {
        if (onoff == 1)
        {
            ChangeHPBar.Invoke(true);
            _Ani.SetBool("DamageTime", true);
        }
        else
        {
            _Ani.SetBool("DamageTime", false);
        }
    }

    void FollowTriggerOn()
    {
        FollowTrigger = true;
    }
    void FollowTriggerOff()
    {
        FollowTrigger = false;
    }

    void KnifeAnimationOn()
    {
        KnifeAnimation = true;
    }
    void KnifeAnimationOff()
    {
        KnifeAnimation = false;
    }

    void HancelReset()
    {
        StartCoroutine(CountTimer());
    }
    public IEnumerator CountTimer()                //일정 시간 공격 받는지 체크
    {
        yield return new WaitForSeconds(2.0f);
        Hansel.GetComponent<Hansel>().inPhaseTwo();
    }
    void KnifeOn()
    {
        KnifeObject.transform.localScale = Vector3.zero;
    }

    void KnifeOff()
    {
        KnifeObject.transform.localScale = new Vector3(1, 1, 1);
    }
    void Hansel_ResetHP()
    {
        ChangeHPBar.Invoke(false);
        Hansel.GetComponent<Hansel>().ResetState_Protected();
    }

    void KnifeEffect()
    {
        KnifeEffect1.SetActive(true);
        KnifeEffect2.SetActive(true);
        KnifeEffect3.SetActive(true);
        KnifeEffect1.GetComponent<ParticleSystem>().Play();
        KnifeEffect2.GetComponent<ParticleSystem>().Play();
        KnifeEffect3.GetComponent<ParticleSystem>().Play();

    }

    void KnifeTraceEnd()
    {
        KnifeEffectPosition.GetComponent<KnifeEffectPosition>().TraceTrigger = false;
    }


    void KnifeDamageEnd()
    {
        KnifeEffectPosition.GetComponent<KnifeEffectPosition>().TraceTrigger = true;
        KnifeEffect1.SetActive(false);
        KnifeEffect2.SetActive(false);
        KnifeEffect3.SetActive(false);
    }

}