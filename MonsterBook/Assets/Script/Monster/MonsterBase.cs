using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using MonsterFSM;
using static UnityEngine.Rendering.DebugUI;


public abstract class MonsterBase : MonoBehaviour, IEntity, ICutOff
{

       



    private Rigidbody rigd;
    protected Rigidbody grigd => rigd;





    // 일단 임시로 protected로 설정 해놓겠습니다.
    [SerializeField] private string MonsterID;
    [SerializeField] private int HP;
    [SerializeField] private float WalkSpeed;
    [SerializeField] private float RunSpeed;
    [SerializeField] private Transform[] PatrolPoint;
    [SerializeField] private float MoveDistance;

    [SerializeField] private GameObject Dead_Object;
    [SerializeField] private GameObject Alive_Object;
    [SerializeField] private GameObject[] Effects;
    [SerializeField] private float IdleTime;
    [SerializeField] private float ExplosionForce;
    
    [SerializeField] private Animator AnimatorCtrl;
    [SerializeField] private MonsterAnimationTrigger AnimationTrigger;
    



    protected MonsterFSMBase FSM;
    private Collider PlayerColloder;
    private Vector3 ExplosionVector;




    public float gIdleTime => IdleTime;

    // 일단 제한자를 protected로 설정 해놨습니다.
    public string gMonsterID { get { return MonsterID; } protected set { MonsterID = value; } }
    public int gHP { get { return HP; } protected set { HP = value; } }
    public float gWalkSpeed { get { return WalkSpeed; } protected set { WalkSpeed = value; } }
    public float gRunSpeed { get { return RunSpeed; } protected set { RunSpeed = value; } }
    public Transform[] gPatrolPoint { get { return PatrolPoint; } protected set { PatrolPoint = value; } }
    public float gMoveDistance { get { return MoveDistance; } protected set { MoveDistance = value; } }

    public Vector3 gExplosionVector { get { return ExplosionVector; } protected set{ ExplosionVector = value; } }
    public int CurrentPatrol { get; set; }
    public MonsterFSMBase gFSM => FSM;
    public GameObject[] gEffects => Effects;    
    public GameObject gAlive_Object => Alive_Object;
    public GameObject gDead_Object => Dead_Object;
    public float gExplosionForce => ExplosionForce;
    public MonsterAnimationTrigger gAnimationTrigger => AnimationTrigger;
    public Animator gAnimator => AnimatorCtrl;
    

    public Collider gPlayerColloder
    {
        get
        {
            if (PlayerColloder == null)
                PlayerColloder = transform.GetComponent<Collider>();

            return PlayerColloder;
        }
    }
    
    public Bounds gBounds
    {
        get
        {
            if (PlayerColloder == null)
                PlayerColloder = transform.GetComponent<Collider>();

            return PlayerColloder.bounds;
        }
    }


    protected abstract void DeadSound();
    protected abstract void HitSound();



    public bool BoxCastCheck()
    {        
        float capsuleScale = Mathf.Max(transform.lossyScale.x, transform.lossyScale.z);
        RaycastHit hitinfo;
        var Hitoffset = new Vector3(0.0f, transform.localScale.y * 0.5f, 0.0f);
        if (Physics.BoxCast(transform.position + Hitoffset, transform.lossyScale * 0.4f, transform.forward, out hitinfo, Quaternion.identity, 1f))
        {
            if (hitinfo.transform.CompareTag("Monster") || hitinfo.transform.name == "ViewCollider")
                return false;            
            else                         
                return true;            
        }
        return false;
    }


    protected virtual void IsDead()
    {
        if (gHP <= 0)
        {
            bool IsDead = FSM is Monster_Dead;
            if (!IsDead)
            {
                gameObject.GetComponent<Collider>().enabled = false;
                FSM = MonsterFSMCreator.MonsterDeadFSM(this);
                DeadSound();
            }

        }
    }




    protected virtual void Start()
    {
        rigd = GetComponent<Rigidbody>();
        AnimatorCtrl = GetComponentInChildren<Animator>();
    }

    protected virtual void Update()
    {
        if (FSM != null)
        {
            if (FSM.TransitionFunc == null)
            {
                FSM.TransitionFunc = Transition;
            }

            var Trans = FSM.TransitionFunc();
            if (Trans != null)
                FSM = Trans;
            FSM.UpdateExecute();
        }
    }

    protected virtual void FixedUpdate()
    {
        if (FSM != null)
            FSM.FixedExecute(rigd);
    }

    public virtual void OnDamage(int damage, Vector3 pos)
    {
        EffectPoolManager.gInstance.LoadEffect("FX_Hit_Enemy", transform);

        if (gHP >= 0)
            gExplosionVector = pos;

        gHP -= damage;
        
        if (gHP >= 0)
        {
            AnimationTrigger.init();            
            FSM = MonsterFSMCreator.MonsterHitFSM(this);
            HitSound();
        }
    }

    public virtual void OnRecovery(int heal)
    {
        gHP += heal;
    }
    
    public virtual bool CheckCutOff()
    {
        return gHP <= 0.0f;
    }

    public virtual void CutDamage()
    {
        IsDead();
    }

    protected abstract MonsterFSMBase Transition();
}
