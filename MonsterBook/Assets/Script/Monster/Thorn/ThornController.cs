using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;


public class ThornController: MonoBehaviour, IEntity, ICutOff
{
    public enum CurrentState { idle, trace, attack, dead, Hit ,Lost}

    [Header("[Stat]")]
    private string Name = "Thorn";    
    public float MaxHP = 0.0f;           
    public float CurHP;                    
    public float WalkSpeed = 0.1f;     
    public float RunSpeed = 12.0f;      
    public float AttackDelay = 3.0f;      
    public GameObject AttackArea;
    public bool MoveType;  //false == z�� �̵�, true == x���̵�

    [Header("[State/ScanDist]")]
    public CurrentState State = CurrentState.idle;
    public GameObject PatrolPoint1;
    public GameObject PatrolPoint2;

    Animator animator;
    private Transform _transform;
    private Transform playerTransform;
    private bool Patrollook = false;
    public float traceDist = 10.0f;
    public float attackDist = 2.0f;
    private bool isDead = false;

    private bool Motioning = false;
    private bool Possible_Move = true;

    private bool Chasing = false;
    private bool DeadMotioning = false;
    public GameObject BodyParts;
    public bool Invinbool = false;
    private bool CanLook = true;
    public ParticleSystem AttackEffect;

    

    void Start()
    {
        _transform = this.gameObject.GetComponent<Transform>();
        playerTransform = GameObject.FindWithTag("Player").GetComponent<Transform>();
        animator = GetComponent<Animator>();
        CurHP = MaxHP;

        /*
        if (MoveType == true)
        {
            _transform.position = new Vector3(playerTransform.position.x, _transform.position.y, _transform.position.z); //x�� player ����
        }
        else if (MoveType == false)
        {
            _transform.position = new Vector3(_transform.position.x, _transform.position.y, playerTransform.position.z); //z�� player ����
        }
        */

        StartCoroutine(this.CheckState());
        StartCoroutine(this.CheckStateForAction());
    }

    void Update()
    {
        if (Input.GetKey(KeyCode.K))
        {
            CutOff();
        }
    }


    IEnumerator CheckState()
    {
        while(!isDead)
        {
            yield return new WaitForSeconds(0.2f);
            float dist = Vector3.Distance(playerTransform.position, _transform.position);
            if (Motioning == false)     //���� ��������߿��� üũ -> ���ݵ��� �Ÿ����� �־��� �ٸ� State�� �Ǵ��� ���ݸ���� ����°� ����
            {
                if(Possible_Move == true)

                    if (dist <= attackDist)
                    {
                        State = CurrentState.attack;
                    }
                    else if (dist <= traceDist)
                    {
                        State = CurrentState.trace;
                    }
                    else
                    {
                        if (Chasing == true)
                        {
                            State = CurrentState.Lost;
                        }
                        else
                        {
                            State = CurrentState.idle;
                        }
                    }
            }

        }
        if(CurHP <= 0)
        {
            State = CurrentState.dead;
        }
    }

    IEnumerator CheckStateForAction()
    {
        while(!isDead) 
        {
            AttackArea.SetActive(false);
            switch (State)
            {
                case CurrentState.idle:
                    Patrol();
                    animator.Play("Walk");
                    break;
                case CurrentState.trace:
                    Chasing = true;
                    LookTarget(playerTransform);
                    animator.Play("Run");
                    if (MoveType == false)
                    {
                        transform.position = new Vector3(Vector3.MoveTowards(transform.position, playerTransform.position, RunSpeed * Time.deltaTime).x, transform.position.y, transform.position.z);
                    }
                    else if(MoveType == true)
                    {
                        transform.position = new Vector3(transform.position.x, transform.position.y, Vector3.MoveTowards(transform.position, playerTransform.position, RunSpeed * Time.deltaTime).z);
                    }

                    break;
                case CurrentState.attack:
                    LookTarget(playerTransform);
                    Attack();                           //�ڵ尡 �� �Լ��� ��ü   //Attack, Hit
                    break;
                case CurrentState.Hit:
                    Hit();
                    break;
                case CurrentState.Lost:
                    animator.Play("Idle");
                    if (animator.GetCurrentAnimatorStateInfo(0).IsName("Idle") && animator.GetCurrentAnimatorStateInfo(0).normalizedTime >= 0.9f)
                    {
                        Motioning = false;
                        Chasing = false;
                    }
                    break;
                case CurrentState.dead:
                    animator.Play("Death");
                    DeadMotioning = true;
                    Motioning = true;
                    if (animator.GetCurrentAnimatorStateInfo(0).IsName("Death") && animator.GetCurrentAnimatorStateInfo(0).normalizedTime >= 0.9f)
                    {
                        Motioning = false;
                        DeadMotioning = false;
                        isDead = true;
                        this.gameObject.SetActive(false);
                    }
                    break;

            }
            yield return null;
        }
    }

    public bool CheckCutOff()
    {
        if (CurHP <= 0)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    void AttackEffectStart()
    {
        AttackEffect.Play();
    }

    public void CutDamage()
    {
        gameObject.SetActive(false);
        BodyParts.SetActive(true);
    }

    void CutOff()
    {
        this.gameObject.SetActive(false);
        BodyParts.SetActive(true);

    }

    public void OnDamage(int damage, Vector3 pos)
    {
        Debug.LogError("���ù��� �ǰ�");
        if (Invinbool == false)
        {
            if (CheckCutOff())
            {
               CutOff();
            }
            CurHP -= damage;
            State = CurrentState.Hit;
            Motioning = true;
        }

    }
    public void OnRecovery(int heal)
    {

    }
    void Attack()
    {
        CanLook = false;
        Possible_Move = false;
        animator.Play("Attack");
        if (animator.GetCurrentAnimatorStateInfo(0).IsName("Attack") && animator.GetCurrentAnimatorStateInfo(0).normalizedTime >= 1f)
        {
            State = CurrentState.idle;
            Motioning = false;
            AttackArea.SetActive(false);
            Possible_Move = true; //trace walk���·� �����ֳ�
            Invinbool = false;
            CanLook = true;
        }
        if (animator.GetCurrentAnimatorStateInfo(0).IsName("Attack") && animator.GetCurrentAnimatorStateInfo(0).normalizedTime >= 0.35f)
        {
            Motioning = true;
            AttackArea.SetActive(true);
            Invinbool = true;
        }

        if (animator.GetCurrentAnimatorStateInfo(0).IsName("Attack") && (animator.GetCurrentAnimatorStateInfo(0).normalizedTime <= 0.35f ||
                                                                                animator.GetCurrentAnimatorStateInfo(0).normalizedTime >= 0.75f))
        {
            Motioning = false;
            AttackArea.SetActive(false);
            Invinbool = false;

        }
    }
    void Hit()
    {
        if (DeadMotioning == false)
            {
                animator.Play("Hit");
                Motioning = true;
                if (animator.GetCurrentAnimatorStateInfo(0).IsName("Hit") && animator.GetCurrentAnimatorStateInfo(0).normalizedTime >= 1.0f)
                {
                    Motioning = false;
                    Possible_Move = true;
                    if (CurHP <= 0)
                    {
                        //State = CurrentState.dead;
                    }
                    else
                    {
                        State = CurrentState.idle;
                    }
                }
            }
        

    }
    void LookTarget(Transform Target)
    {
        if (CanLook == true)
        {
            Vector3 dir = Target.position - this.transform.position;
            Vector3 dirXZ = new Vector3(dir.x, 0f, dir.z);

            if (dirXZ == Vector3.zero)
                return;

            this.transform.rotation = Quaternion.RotateTowards(this.transform.rotation, Quaternion.LookRotation(dirXZ), 300 * Time.deltaTime);
        }
    }
    void Patrol()
    {
        if (MoveType == false)
        {

            if (Patrollook == false) //PatrolPoint1 -> PatrolPoint2�� �̵�
            {
                transform.position = Vector3.MoveTowards(transform.position, PatrolPoint2.transform.position, WalkSpeed * Time.deltaTime);
                LookTarget(PatrolPoint2.transform);
                if (transform.position.x == PatrolPoint2.transform.position.x)
                {
                    Patrollook = true;
                }

            }
            else                    //PatrolPoint1 -> PatrolPoint2�� �̵�
            {
                transform.position = Vector3.MoveTowards(transform.position, PatrolPoint1.transform.position, WalkSpeed * Time.deltaTime);
                LookTarget(PatrolPoint1.transform);
                if (transform.position.x == PatrolPoint1.transform.position.x)
                {
                    Patrollook = false;
                }
            }
        }

        if (MoveType == true)
        {

            if (Patrollook == false) //PatrolPoint1 -> PatrolPoint2�� �̵�
            {
                transform.position = Vector3.MoveTowards(transform.position, PatrolPoint2.transform.position, WalkSpeed * Time.deltaTime);
                LookTarget(PatrolPoint2.transform);
                if (transform.position.z == PatrolPoint2.transform.position.z)
                {
                    Patrollook = true;
                }

            }
            else                    //PatrolPoint1 -> PatrolPoint2�� �̵�
            {
                transform.position = Vector3.MoveTowards(transform.position, PatrolPoint1.transform.position, WalkSpeed * Time.deltaTime);
                LookTarget(PatrolPoint1.transform);
                if (transform.position.z == PatrolPoint1.transform.position.z)
                {
                    Patrollook = false;
                }
            }
        }
    }
}
