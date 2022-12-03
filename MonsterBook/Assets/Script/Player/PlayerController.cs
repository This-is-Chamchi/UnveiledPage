using System.Collections.Generic;
using System.Collections;
using System;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.Animations.Rigging;

#region ENUM BOIS
public enum PlayerState {
    IdleState,
    WalkState,
    DashState,
    AttackState,
    SpecialAttackState,
    JumpState,
    WireThrowState,
    WireState,
    DeadState,
    HitState,
    CuttingState,
    KnockBackState,
    JumpAttackState,
    PatrolState
}

public enum Axis    {   
    XAxis,
    ZAxis,
}

public enum LookAxis    {
    ZPlusAxis,
    XMinusAxis,
    ZMinusAxis,
    XPlusAxis,
}

public enum CURRENT_TERRAIN {
    Grass,
    Wood,
    Rock,
    Snow,
    Ice
}
#endregion

[Serializable]  public class StringParticle : SerializableDictionary<String, ParticleSystem> { }

public class SomeComparer : IEqualityComparer<PlayerState>  {
    bool IEqualityComparer<PlayerState>.Equals(PlayerState x, PlayerState y) { return (int)x == (int)y; }
    int IEqualityComparer<PlayerState>.GetHashCode(PlayerState obj) { return ((int)obj).GetHashCode(); }
}

public class PlayerController : MonoBehaviour, IEntity, IKnockBack, IRotate {
    #region Component
    public CapsuleCollider collid { get; private set; }
    public InputManager input { get; set; }
    [HideInInspector] public Rigidbody rigid;
    [HideInInspector] public UIController ui;
    [HideInInspector] public Animator ani;

    #endregion

    #region State    
    private Dictionary<PlayerState, IState> stateDic = new Dictionary<PlayerState, IState>(new SomeComparer());
    private IState curState;
    private IState prevState;

    #endregion

    #region PlayerValue
    [Header("=====[Player State]=====")]
    [ReadOnly] public PlayerState state;
    [HideInInspector] public Axis curAxis;
    [HideInInspector]public bool prevInput;
    [Tooltip("init HP")]private int m_maxHP = 90;  
    [ReadOnly][SerializeField] private int m_curHP;
    [Tooltip("init Sp , max 100")] public int MaxSP;

    [HideInInspector] public int attackCount;                   //attck counter . max 3.
    [HideInInspector] public bool CheckDamage = false;          //Check player get hit or something. same m_CheckDamage. this thing is for other script.
    [HideInInspector] public bool CheckJumpAttack = false;      //Check player Attack with jump
    private float m_SetJumpLoopTimer = 1.0f;                    //player falling timer.
    public float InvinsibleTime = 1f;                           //running time for player invinsible time when player get hit or something.
    public bool isSecondEnable = false;                         //For SAtatck the Check Second Stage
    public bool Player_Intro = false;                           //Player Intro Scene Set bool 
    public bool invinBool { get; set; }
    public Transform[] playerPatrolLocaiton;
    [Space(3)]
    #endregion

    #region PlayerWeapon => One  Sword
    [Space(10)]
    [Header("=====[Player Weapon One Hand Sword]=====")]
    [Tooltip("한손검 공격 데미지")]public int isDamage;
    [Tooltip("궁극기 데미지")]public int Special_Damage;
    [Tooltip("한손검 걷기 속도")] public float m_OneHandWalkSpeed = 9.6f;
    [SerializeField][Tooltip("한손검 점프 Force")] private float m_OneHandJumpForce = 14.0f;
    [SerializeField][Tooltip("한손검 데쉬 Force")] private float m_OneHandDashForce = 14.0f;
    [SerializeField][Tooltip("한손검 Dash 지속시간")] private float m_OneHandDashRunTime = 0.5f;
    [SerializeField][Tooltip("한손검 Dash 인풋 딜레이")] private float m_OneHandDashDelay = 1.0f;

    private GameObject m_Delete_Scissors;       //Player Production Weapon
    private GameObject m_Scissors;              //Player Weapon

    [Space(10)]

    [Tooltip("한손검 1타 진행시간")] public float OneHandAttack_1 = 0.37f;
    [Tooltip("한손검 2타 진행시간")] public float OneHandAttack_2 = 0.33f;
    [Tooltip("한손검 3타 진행시간")] public float OneHandAttack_3 = 0.56f;

    [HideInInspector] public float jumpForce => m_OneHandJumpForce;                     //player jump foce(animator)
    [HideInInspector] public float dashForce => m_OneHandDashForce;                     //player dash force (animator)
    [HideInInspector] public float dashRunningTime => m_OneHandDashRunTime;             //player dash running time
    [HideInInspector] public float dashDelayTime => m_OneHandDashDelay;                 //player dash input (*Key) delay


    #endregion

    #region Move Value
    [Space(10)]
    [Header("=====[Move Value]=====")] 
    public LayerMask wallLayer;
    public LayerMask groundLayer;
    public LayerMask wireBlock;                                                         //made Wire Lay cant Thru the ground
    public bool checkJump { get; set; }
    [SerializeField] private LayerMask monsterLayer;
    [SerializeField] CURRENT_TERRAIN currentTranin;                                     //Check Ground For Sound

    [HideInInspector] public Vector3 lookVector;                                        //check player look dir,
    [HideInInspector] public float walkVector;                                          //Check player Walk dir,
    [HideInInspector] public bool Falling = false;                                      //check player is falling,
    [HideInInspector] public bool isGround;                                             //check player is Grounded,
    [HideInInspector] public int isJump = 0;
    [Tooltip("캐릭터 회전 배속")] protected float RotationSpeed = 6.0f;
    [Tooltip("경사 체크 길이")][SerializeField] private float m_SlopeDistance = 2.0f;
    [Tooltip("경사 체크할 각도")][SerializeField] private float m_MaxAngle = 30.0f;
  
    private AxisRotateObject m_axisRotate;
    
    #endregion

    #region LookatTartget(Wire)
    [Space(10)]
    [Header("=====[Wire Value]=====")]
    [Tooltip("와이어 당기는 힘 ")] public float WireForce = 6f;
    [SerializeField][Tooltip("와이어 탐지 길이")] private float m_WireDistance = 20.0f;
    [Tooltip("와이어 머테리얼 교체")] public Material[] WireMaterial;

    [HideInInspector] public float SaveBouceYPos = .0f;             //Save Wire Pos For Monster Collider Y pos ++
    [HideInInspector] public Transform wireStart;                   //Wire Shot Start Transform
    [HideInInspector] public Transform wirePos;                     //wire target Pos Transform
    [HideInInspector] public GameObject PlayerLookat;               //Lootat Obj => this parent made rolation for wire
    [HideInInspector] public GameObject Arrow_Lookat;               //simple indicator for wire
    [HideInInspector] public Vector2 PlayerAimObj;                  //For PlayerLookat Rotation value,
    [HideInInspector] public Vector3 PlayerAimMouse;                //For PlayerLookat Rotaion Value For Mouse.
    [HideInInspector] public bool SaveMonDetect;                    //save Monster detected value (bool)
    [HideInInspector] public bool isLookTarget = false;             //Moveing Thumstic? ==> true
    [HideInInspector] public bool LockLookTartget = false;          //if player is flying (wire) or something need to Lock the indicator. then made false.
    [HideInInspector] public bool isLockDistance = false;           // check player ~ targer the min distance
    [HideInInspector] public bool isLookDir;                        //check the Thunbstick Hit the ray
    [HideInInspector] public bool isMonsterCheck = false;           //Check the wire detect monster 
    private RaycastHit m_Lookat_hit;
    

    [Space(3)]

    #endregion

    #region Inspector
    [Space(10)]
    [Header("=====[Component Property]=====")]
    [SerializeField] [Tooltip("Change game speed")]private float m_GameSpeed = 1;
    [HideInInspector]public Weapon[] attackWeapon;

    private MultiAimConstraint m_HeadAim_Const;
    private PlayerWeapon_Rigging m_WeaponIK;
    private Rig m_PlayerRig;
    [HideInInspector]public LineRenderer line;
    [HideInInspector]public Transform effectEuler;

    //Controller Setting
    protected bool isVibration = false;                 //Xbox vibration
    protected bool isInfinityVib = false;               //vibration loop
    protected float LeftMoter = 0.0f;
    protected float RightMoter = 0.0f;
    protected float ConRunningTime = 0.3f;
    protected Vector3 m_SaveColSize = Vector3.zero;     //player.collider Pos save

    [Space(10)]
    [Header("====[Effect Prefab]====")]
    [SerializeField]private StringParticle m_Particle;

    #endregion

    #region Initialize

    private void Awake(){   
        collid = GetComponent<CapsuleCollider>();
        input = GetComponent<InputManager>();
        rigid = GetComponent<Rigidbody>();
        ani = GetComponent<Animator>();

        m_WeaponIK = GameObject.Find("RayDown_Weapon").GetComponent<PlayerWeapon_Rigging>();
        m_Scissors = GameObject.Find("Scissors_Player");
        PlayerLookat = GameObject.Find("Lookat");
        Arrow_Lookat = GameObject.Find("Arrow");

        ui = GameObject.FindGameObjectWithTag("UIController").GetComponent<UIController>();
        m_HeadAim_Const = GameObject.Find("HeadAim").GetComponent<MultiAimConstraint>();
        wireStart = GameObject.FindWithTag("Wire_Start").GetComponent<Transform>();
        line = GameObject.Find("LineRenderer").GetComponent<LineRenderer>();
        effectEuler = GameObject.Find("Effect").GetComponent<Transform>();     
        wirePos = GameObject.Find("Wire_Pos").GetComponent<Transform>();

        attackWeapon[3] = GameObject.Find("SAttack_Damage").GetComponent<Weapon>();
        attackWeapon[0] = GameObject.Find("Scissors_00").GetComponent<Weapon>();
        attackWeapon[1] = GameObject.Find("WireAttack").GetComponent<Weapon>();
        attackWeapon[2] = GameObject.Find("Cutting").GetComponent<Weapon>();
        m_PlayerRig = GameObject.Find("Player_Rig").GetComponent<Rig>();
        try{m_Delete_Scissors = GameObject.Find("Scissors_Prop");}
        catch{}
        
    }

    private void Start(){
        int enumCount = Enum.GetValues(typeof(PlayerState)).Length;

        for (int i = 0; i < enumCount; i++){
            var name = ((PlayerState)i).ToString();
            var state = gameObject.AddComponent(Type.GetType(name)) as IState;

            stateDic.Add((PlayerState)i, state);
        }
        PlayerInitialize();
        IntroSection();
    }

    #endregion

    #region Anim Event

    protected void AttackBoxOn(int i)   {attackWeapon[i].Collider(true);}

    public void AttackBoxOff(int i) {attackWeapon[i].Collider(false);}

    protected void AttackForce (int i ){/* if(!CheckWall()) rigid.AddForce(lookVector * i ,  ForceMode.Impulse);*/}

    protected void DashForce()  {
        if(Falling)
            rigid.AddForce(lookVector * dashForce + new Vector3(0, 10), ForceMode.Impulse);
        else
            rigid.AddForce(lookVector * dashForce + new Vector3(0, 3), ForceMode.Impulse);
    }

    protected void JumpForce()  {rigid.AddForce(Vector3.up * jumpForce, ForceMode.Impulse);}

    protected void CheckJump()  {checkJump = true;}

    protected void CheckJumpEnd()   {checkJump = false;}

    protected void AttackEffect(int i)  {m_Particle["Attack" + i.ToString()].Play();}

    public void ParticlePlay(string name)   {m_Particle[name].Play();}

    public void ParticleStopPlay(string name)   {m_Particle[name].Stop(true, ParticleSystemStopBehavior.StopEmittingAndClear);}

    protected void PlayVib()    {SetVibValue(true, 0.5f, 0.5f, 0.1f, false);}

    protected void PlayVib_PlayMiddle() {SetVibValue(true, 0.5f, 0.5f, 0.5f, true); ;}

    protected void PlayVib_PlayHigh()   { SetVibValue(true, 1.0f, 1.0f, 0.5f, true); ;}

    protected void PlayVib_Stop()   {SetVibValue(false, 0.0f, 0.0f, 0.0f, false);}

    public void ParticlShot(string name)    {
        var ParticleDir = 0.0f;
        if(lookVector.x == 1)
            ParticleDir = 0.0f;
        else
            ParticleDir = 180.0f;

        Instantiate(m_Particle[name].gameObject, transform.position, Quaternion.Euler(0, ParticleDir, 0));
    }

    public void SoundShot(string name)  {SoundManager.PlayVFXSound(name , transform.position);}

    public void FootSound() {
        if(isGround){
            switch(currentTranin){
                case CURRENT_TERRAIN.Grass:
                    SoundManager.PlayVFXSound("Player_Foot_Grass" , transform.position);
                break;

                case CURRENT_TERRAIN.Wood:
                    SoundManager.PlayVFXSound("Player_Foot_Wood" , transform.position);
                break;

                case CURRENT_TERRAIN.Rock:
                    SoundManager.PlayVFXSound("Player_Foot_Rock" , transform.position);
                break;

                case CURRENT_TERRAIN.Snow:
                    SoundManager.PlayVFXSound("Player_Foot_Snow" , transform.position);
                break;

                case CURRENT_TERRAIN.Ice:
                    SoundManager.PlayVFXSound("Player_Foot_Ice" , transform.position);

                break;
                default:
                    Debug.Log("Wait. Wut?? >> There is no FootPrint Sound, u need to check FootSound().");
                break;
            }
        }
    }

    protected void AttackSound(int count)  {
        switch(count)   {
            case 1:
                SoundManager.PlayVFXSound("Player_Attack01" , transform.position);       
            break;
            
            case 2:
                SoundManager.PlayVFXSound("Player_Attack02" , transform.position);           
            break;

            case 3:
                SoundManager.PlayVFXSound("Player_Attack03" , transform.position);    
            break;      

            case 4:
                SoundManager.PlayVFXSound("Player_SAttack" , transform.position);
            break;

            case 5:
                SoundManager.PlayVFXSound("Player_SAttack_Sus" , transform.position);
            break;

            default:
                Debug.Log(" There is no Attack Sound. Check Animator ");
            break;
        }
    }

    protected void SetIdle(){if (state != PlayerState.IdleState) ChangeState(PlayerState.IdleState);}

    protected void ShotWire(){line.enabled = true;}

    public void SetWeaponHide(int value)    {
        if(value == 1){
            Player_Intro = false;
            m_Scissors.SetActive(true);
            m_OneHandWalkSpeed = 9.6f;
            try{m_Delete_Scissors.SetActive(false);}
            catch{}
            }
        }

    public void SetSPBefore_2Stage(){
        if(isSecondEnable){
            ui.SP_Using = true;
            MaxSP = 100;
        }
    }

    #endregion

//==================================================================//
#region No Touch :(

    public void ChangeState(PlayerState next)   {
        prevState = curState;
        prevState.OnStateExit(this);
        stateDic[next].OnStateEnter(this);
        curState = stateDic[next];
        state = next;
    }

    public void AgainState()    {
        curState.OnStateExit(this);
        curState.OnStateEnter(this);
    }

    public void ChangePatrol(){ChangeState(PlayerState.PatrolState);}

    private float m_HeadUpWeight = .0f;
    private void LookUpHead()   {
        m_HeadAim_Const.weight = 1;
        m_HeadUpWeight += Time.deltaTime;
        if(m_HeadUpWeight >= 1 )
            m_HeadUpWeight = 1f;
        m_HeadAim_Const.weight = m_HeadUpWeight;
    }

    private void ResetLookUpHead()  {
        m_HeadUpWeight -= Time.deltaTime;
        if(m_HeadUpWeight <= 0 )    {
            m_HeadAim_Const.weight = 0;
            m_HeadUpWeight = .0f;
            }
        m_HeadAim_Const.weight = m_HeadUpWeight;
    }

    public void Walk()  {        //if Player contact the wall, made velocity to zero. if not. can stay walk.
        if (CheckMonster() || CheckWall())  rigid.velocity = new Vector3(0, rigid.velocity.y);
        else if (!CheckWall())  {
            var vector = Mathf.Abs(walkVector);
            var move = new Vector3(lookVector.x * vector * m_OneHandWalkSpeed, rigid.velocity.y, 0);
            rigid.velocity = move;
        }
        else    return;
    }

    #region Vibration For Pad 
    protected void SetVibrationXbox(float leftMorter , float RightMorter, float Time , bool infini) {   //Pad vibration
        if (Gamepad.current == null) return;
        else    {
            if (isVibration)    {
                Gamepad.current.SetMotorSpeeds(leftMorter, RightMorter);
                if (!infini)    StartCoroutine(StartCountVibration(Time));
            }
            else if (!isVibration)  Gamepad.current.SetMotorSpeeds(0, 0);
        }
    }

    public void SetVibValue(bool Yeet ,float LM, float RM, float time , bool loop)  {
        isVibration = Yeet;
        LeftMoter = LM;
        RightMoter = RM;
        ConRunningTime = time;
        isInfinityVib = loop;
    }

    IEnumerator StartCountVibration(float num)  {
        yield return YieldInstructionCache.waitForSeconds(num);
        isVibration = false;
    }

    #endregion

    #region Command
    //~ CMD
    public void SetSTR(string value)    {
        var Attack_Damage = int.Parse(value);
        this.isDamage = Attack_Damage;
    }

    bool cmdInvBool;
    public void SetInv(string value)    {
        var val = bool.Parse(value);
        cmdInvBool = val;
    }

    public void SetHP(string value)     {
        var val = int.Parse(value);
        m_curHP = val;
    }

    public void SetMaxHP(string value)  {
        var val = int.Parse(value);
        m_maxHP = val;
    }

    #endregion

    #region Getter
    public PlayerState GetCurState() { return state; }

    public IState GetPrevState() { return prevState; }

    public IState GetStateDictionary(PlayerState state) { return stateDic[state]; }

    #endregion

    private void IntroSection() {       //Introl Part player Setter
        if (Player_Intro)    {
            ani.SetBool("isIntro" , true);
            m_OneHandWalkSpeed = 4.8f;
            m_Scissors.SetActive(false);
            ui.SP_Using = true;
        }
        else    {
            ani.SetBool("isIntro" , false);
            m_OneHandWalkSpeed = 9.6f;
            m_PlayerRig.weight = 1.0f;
        }
    }

    public void IntroProduction()  {     //Introl Part player Setter    
            ani.SetTrigger("Intro");
            input.SetInputAction(false);
    }
    
    private void OnDrawGizmos() {
        Gizmos.color = Color.red;
        if (Application.isPlaying)  {
            Gizmos.DrawWireCube(collid.bounds.center + new Vector3(0, -collid.height/2), new Vector3(0.35f, 0.5f, 0.5f)); //Ground
            Gizmos.color = Color.yellow;
            Gizmos.DrawWireCube(collid.bounds.center + lookVector * collid.radius * 2, new Vector3(0.5f, 1.0f, 0.3f));  //Front
        }

        if (isLookTarget)   {
            if (isLookDir)  {
                Gizmos.color = Color.green;
                Gizmos.DrawWireSphere(PlayerLookat.transform.position + PlayerLookat.transform.up * m_Lookat_hit.distance, PlayerLookat.transform.lossyScale.x *1.5f);
            }
            else
                return;
        }
    }

#endregion
//==================================================================//

protected void FixedUpdate()  {
        Time.timeScale = m_GameSpeed;
        curState.OnStateExcute(this);
        WireTartgetFollow();
        CheckGround();
        CheckGroundForSound();
        CheckRotation();

        //=================Debug . ing=================//
        if (Input.GetKeyDown(KeyCode.F11))  {
            //Cursor.visible = false;
            //IntroProduction();
            OnDamage(90 , transform.position);
        }
        if(Input.GetKeyDown(KeyCode.F5)) input.SetInputAction(true);
        //=============================================//
    }

protected void Update() {
        CheckSlop();
        CheckIntro();        
        SetVibrationXbox(LeftMoter, RightMoter, ConRunningTime, isInfinityVib);
    }

protected void WireTartgetFollow()  {         //Xbox controller Thumbstick Parts.
        if (isLookTarget)   {
            if (Gamepad.current == null)    {
                PlayerAimMouse.z = Camera.main.farClipPlane * 100;
                Vector2 WorldPosition = Camera.main.ScreenToWorldPoint(PlayerAimMouse);
                var m_MouseRotation = -Mathf.Atan2( WorldPosition.x - transform.position.x , WorldPosition.y - transform.position.y) * Mathf.Rad2Deg;
                PlayerLookat.transform.rotation = Quaternion.Euler(0, 0, m_MouseRotation);
            }
            else    {
                var m_ControllRot = -Mathf.Atan2(PlayerAimObj.x, PlayerAimObj.y) * Mathf.Rad2Deg;
                PlayerLookat.transform.rotation = Quaternion.Euler(0, 0, m_ControllRot);
            }
            Arrow_Lookat.SetActive(true);

#region  Check Bool With Ray
            //Check Wire Obj
            if(Physics.SphereCast(PlayerLookat.transform.position, PlayerLookat.transform.lossyScale.x * 1.5f,PlayerLookat.transform.up, out m_Lookat_hit, m_WireDistance , wireBlock)){   
                Debug.DrawRay(PlayerLookat.transform.position ,PlayerLookat.transform.up * m_WireDistance , Color.blue );
                if(m_Lookat_hit.collider.CompareTag("Monster")  || (m_Lookat_hit.collider.CompareTag("WireNode")) || (m_Lookat_hit.collider.CompareTag("Boss"))) isLookDir = true;
                else    isLookDir = false;
            }
            else{   
                Debug.DrawRay(PlayerLookat.transform.position ,PlayerLookat.transform.up * m_WireDistance , Color.red ) ; 
                isLookDir = false;
            }

            //Check Monster Obj
            RaycastHit monster_hit;
            isMonsterCheck = Physics.SphereCast(PlayerLookat.transform.position, PlayerLookat.transform.lossyScale.x * 1.5f,
            PlayerLookat.transform.up, out monster_hit, m_WireDistance, monsterLayer);

#endregion

            var Distance = Vector3.Distance(transform.position, m_Lookat_hit.point);
            if (isLookDir && Distance >= 4) {

                wirePos.SetParent(null , true);
                wirePos.rotation = Quaternion.identity;
                isLockDistance = true;
                   
                if(isMonsterCheck)     {
                    SaveBouceYPos = m_Lookat_hit.collider.bounds.size.y / 2;        //Save contect Col half of size.
                    var yMiddle = new Vector3(m_Lookat_hit.transform.position.x  , m_Lookat_hit.transform.position.y + SaveBouceYPos, 0 );
                    wirePos.position = yMiddle;
                }
                else    wirePos.position = m_Lookat_hit.transform.position;

                ui.SetWireAim(wirePos.position, true);
                LookUpHead(); 
            }
            else    {   
                isLockDistance = false;
                ResetLookUpHead();
                ui.SetWireAim(wirePos.position, false);
                return;
            }
        }
        else    {
            ResetLookUpHead();
            Arrow_Lookat.SetActive(false);
            ui.SetWireAim(wirePos.position, false);
            return; 
        }
    }

    #region Setter
    public void SetWalkVector(float value)  {       //Walk direction\
        if (Mathf.Abs(value) > 0.2) {
            walkVector = value;
            ani.SetFloat("WalkSpeed", Mathf.Abs(walkVector));
        }
        else    {
            walkVector = 0;
            ani.SetFloat("WalkSpeed", Mathf.Abs(walkVector));
        }
    }

    public void SetTimeScale(float speed)   {   m_GameSpeed = speed;    }

    public void SetSTR(int value) { isDamage = value; }

    public void SetInvincible(bool value) { invinBool = value; }

    public void SetCurHP(int hp) { m_curHP = hp; }

    public void SetMaxHP(int hp) { m_maxHP = hp; }

    public void SetMaxSp(int sp) { MaxSP = sp; }

    public void SetThrowState(bool value)   {
        input.SetInputAction(!value);
        rigid.isKinematic = value;
    }

    #endregion

    #region Interface
    
    public void OnDamage(int damage, Vector3 pos)   {       
        if (invinBool || cmdInvBool || state == PlayerState.DeadState || Player_Intro) return;

        CheckDamage = true;
        m_curHP -= damage;
        ParticlePlay("Hit");
        ui.SetHP(m_curHP);

        #region lookDir
        var val = transform.position.x < pos.x ? Vector3.right : Vector3.left;
        lookVector = val;
        transform.localRotation = Quaternion.Euler(0, 90 * val.x, 0);
        #endregion

        if (m_curHP <= 0)   {
            m_curHP = 0;
            m_WeaponIK.m_WeaponIKSet.weight = 0;

            SoundShot("Player_Dead");
            SoundShot("Player_Dead_Voice");
            ChangeState(PlayerState.DeadState);
            return;
        }

        if (state != PlayerState.WireThrowState)    ChangeState(PlayerState.HitState);
        DamageBoolChecker(1);
    }

    public void OnRecovery(int heal){   Debug.Log("Recovery");  }

    public void Dead(){   Debug.Log("Dead");  }

    public void CheckRotate(AxisRotateObject ax){   m_axisRotate = ax;  }

    public void Rotate(Vector3 pos) {
        if (m_axisRotate == null) return;
        curAxis = curAxis == Axis.XAxis ? Axis.ZAxis : Axis.XAxis;
        if (curAxis == Axis.XAxis) rigid.constraints = RigidbodyConstraints.FreezePositionZ | RigidbodyConstraints.FreezeRotation;
        else rigid.constraints = RigidbodyConstraints.FreezePositionX | RigidbodyConstraints.FreezeRotation;
        transform.position = new Vector3(pos.x, transform.position.y, pos.z);        
        SetWalkVector(walkVector);
    }

    public void KnockBack(Vector3 direction)    {
        if (state == PlayerState.KnockBackState) return;
        ChangeState(PlayerState.KnockBackState);
        rigid.velocity = Vector3.zero;
        Debug.Log(direction);
        var look = direction.x < this.transform.position.x ? -1 : 1;
        rigid.AddForce(direction * look , ForceMode.Impulse);
    }

    private void PlayerInitialize() {
        curState = stateDic[PlayerState.IdleState];

        m_curHP = 90;
        ui.SetHP(m_curHP);
        ui.SetSp(MaxSP);

        rigid.velocity = Vector3.zero;
        m_SaveColSize = collid.center;
        lookVector = Vector2.right;
        m_PlayerRig.weight = .0f;
        CheckJumpAttack = false;
        SaveMonDetect = false;
        CheckDamage = false;
        attackCount = 1;
        isJump = 1;
        
        attackWeapon[0].SetDamage(isDamage);
        attackWeapon[1].SetDamage(isDamage * 3);
        attackWeapon[3].SetDamage(Special_Damage);

        line.SetPosition(0, Vector3.zero);
        line.SetPosition(1, Vector3.zero);

        //CameraController.SetCameraView();
        if (curAxis == Axis.XAxis) rigid.constraints = RigidbodyConstraints.FreezePositionZ | RigidbodyConstraints.FreezeRotation;
        else rigid.constraints = RigidbodyConstraints.FreezePositionX | RigidbodyConstraints.FreezeRotation;
    }

    #endregion

    #region Coroutine

    private IEnumerator DamageBoolChecker(int num)  {
        // when player's  get damaged, made CheckDamage => true to false. (wire skill)
        yield return YieldInstructionCache.waitForSeconds(num);
        if(CheckDamage) CheckDamage = false;
    }

    #endregion

    #region Check Func

    public void CheckGround()   {
        if(CheckDamage || m_curHP <= 0) return;
        
        isGround = Physics.BoxCast(collid.bounds.center, new Vector3(0.35f, 0.5f, 0.5f),
            -transform.up, Quaternion.identity, collid.height/2, groundLayer);
        //N sec after jump , play the falling animation (if Jump attacking, then dosent work.)
        if (!isGround && !LockLookTartget &&
         state != PlayerState.AttackState && state != PlayerState.DashState )    {

                m_WeaponIK.m_WeaponIKSet.weight = 0;
                ParticleStopPlay("Run");

                if(!CheckJumpAttack)    {
                    m_SetJumpLoopTimer += Time.fixedDeltaTime;
                    if (m_SetJumpLoopTimer >= 0.2f) {
                        m_SetJumpLoopTimer = 0;
                        ani.SetBool("FallingLoop", true);
                        ani.Play("JumpFalling");
                    }
                }
                else    return;
            }
        else    {
            m_SetJumpLoopTimer = 0; 
            ani.SetBool("FallingLoop", false);
        }

        if(rigid.velocity.y < -1)   Falling = true;
        else    Falling = false;
    }

    public void CheckGroundForSound()   {
        RaycastHit[] hit;
        hit = Physics.RaycastAll(transform.position, Vector3.down, 1.0f);
        //Debug.DrawRay(transform.position,Vector3.down * 1.0f);
        foreach (RaycastHit rayhit in hit)  {
            if (rayhit.transform.gameObject.CompareTag("Grass"))    {
                currentTranin = CURRENT_TERRAIN.Grass;
            }
            else if (rayhit.transform.gameObject.CompareTag("Wood"))    {
                currentTranin = CURRENT_TERRAIN.Wood;
            }
            else if (rayhit.transform.gameObject.CompareTag("Rock"))    {
                currentTranin = CURRENT_TERRAIN.Rock;
            }
            else if (rayhit.transform.gameObject.CompareTag("Snow"))    {
                currentTranin = CURRENT_TERRAIN.Snow;
            }
            else if (rayhit.transform.gameObject.CompareTag("Ice")) {
                currentTranin = CURRENT_TERRAIN.Ice;
            }
        }
    }

    public bool CheckAttack()   {
        RaycastHit[] target = Physics.BoxCastAll(transform.position, new Vector3(3.5f, 1.5f, 2), lookVector, Quaternion.identity, 2.8f, monsterLayer);

        if (target.Length == 0) return false;

        for (int i = 0; i < target.Length; i++) {
            ICutOff cut = target[i].collider.GetComponent<ICutOff>();

            if (cut != null)
                if (cut.CheckCutOff()) return true;
        }
        return false;
    }

    public bool CheckWall() {return Physics.BoxCast(collid.bounds.center, new Vector3(0.5f, 1.0f, 0.3f), lookVector, Quaternion.identity, collid.radius * 2, wallLayer);}

    public bool CheckGround_ForWireAttack() {
        return Physics.BoxCast(collid.bounds.center, new Vector3(0.3f, 1.0f, 0.3f),
            lookVector, Quaternion.identity, collid.radius * 2, groundLayer);
    }

    public bool CheckMonster()  {return Physics.BoxCast(collid.bounds.center, new Vector3(0.4f, 1.1f, 0.5f), lookVector, Quaternion.identity, collid.radius * 2, monsterLayer);}

    public void CheckRotation() {
        var m_value = walkVector > 0 ? 1 : -1;
        if (walkVector != 0 && (CheckState(PlayerState.WalkState) || CheckState(PlayerState.JumpState) ||
            CheckState(PlayerState.IdleState)))
            lookVector = curAxis == Axis.XAxis ? new Vector3(m_value, 0, 0) : new Vector3(0, 0, m_value);
         
        var m_target = Quaternion.identity;
        if (curAxis == Axis.XAxis)
            m_target = Quaternion.Euler(0, 91 * lookVector.x, 0);
        else       
            m_target = lookVector.z == 1 ? Quaternion.Euler(0, 1f, 0) : Quaternion.Euler(0, 181f, 0);
        
        transform.rotation = Quaternion.Lerp(transform.rotation, m_target, Time.deltaTime * RotationSpeed);
    }

    public void  CheckSlop(){
        RaycastHit m_SlopeHit;
        var m_PlayerPos = new Vector3(transform.position.x , transform.position.y + 1 , 0);
        Ray m_ray  = new Ray(m_PlayerPos , Vector3.down);
        Debug.DrawRay(m_PlayerPos , Vector3.down * m_SlopeDistance);
        if(Physics.Raycast(m_ray, out m_SlopeHit , m_SlopeDistance , groundLayer))
        {   
            var m_Angle = Vector3.Angle(Vector3.up , m_SlopeHit.normal);

            if(m_Angle > 0 && m_Angle <= m_MaxAngle )   {
                if(m_Angle <= 20 && m_Angle > 10)
                    collid.center = new Vector3(0.0f , 1.56f, 0.0f);
                if(m_Angle <= 30 && m_Angle > 20)
                    collid.center = new Vector3(0.0f , 1.66f, 0.0f);
            }
            else            
                collid.center = m_SaveColSize;
            return;
        }
        return;
    }

    public bool CheckState(PlayerState state) { return this.state == state; }

    public void _CheckDamage()  {
        if (CheckDamage)    {
            LockLookTartget = false;
            line.enabled = false;
            CheckDamage = false;
            IWireEffect IWE = GetComponent<IWireEffect>();
            if(IWE != null) IWE.Hit(false);
            ChangeState(PlayerState.HitState);
        }
    }
    
    protected void CheckIntro() {    //Check Player Intro
        if (ani.GetCurrentAnimatorStateInfo(0).IsName("Player_S_Intro") &&
        ani.GetCurrentAnimatorStateInfo(0).normalizedTime >= .95f)  {
            Player_Intro = false;
            IntroSection();
            return;
        }
        else return;
    }

    #endregion    
}