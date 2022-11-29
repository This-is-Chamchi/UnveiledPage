using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;


public class MacaronController : MonoBehaviour, IEntity, ICutOff
{
    public enum CurrentState { idle, trace, attack,Hit}

    [Header("[Stat]")]
    private string Name = "Macaron";    
    public float MaxHP = 20.0f;           
    public float CurHP;                    
    public float WalkSpeed = 0.1f;     
    public float RunSpeed = 12.0f;      
    public float AttackDelay = 3.0f;      
    public GameObject AttackArea;
    public bool MoveType;

    [Header("[State/ScanDist]")]
    public CurrentState State = CurrentState.idle;

    Animator animator;
    private Transform _transform;
    private Transform playerTransform;
    private GameObject player;
    public float attackDist = 2.0f;
    private bool isDead = false;
    private bool Motioning = false;
    private bool Chasing = false;
    private bool DeadMotioning = false;
    public bool BounddaryAttack = false;
    public GameObject BodyParts;
    private bool Possible_Move = true;
    public ParticleSystem AttackEffect;

    void Start()
    {
        _transform = this.gameObject.GetComponent<Transform>();
        playerTransform = GameObject.FindWithTag("Player").GetComponent<Transform>();
        animator = GetComponent<Animator>();
        CurHP = MaxHP;
        StartCoroutine(this.CheckState());
        StartCoroutine(this.CheckStateForAction());
        Time.timeScale = 0.1f;
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
            if (Motioning == false)     
            {
                if (Possible_Move == true)
                {
                    if (BounddaryAttack == true) 
                    {
                        if (dist <= attackDist)
                        {
                            State = CurrentState.attack;
                        }
                        else if (dist > attackDist)
                        {
                            State = CurrentState.trace;
                        }
                    }
                    else
                    {
                        State = CurrentState.idle;
                    }
                }
            }
            
        }

    }

    IEnumerator CheckStateForAction()
    {
        yield return new WaitForSeconds(0.2f);
        float dist = Vector3.Distance(playerTransform.position, _transform.position);
        while (!isDead) 
        {
            AttackArea.SetActive(false);
            switch (State)
            {
                case CurrentState.idle:
                    animator.Play("idle");
                    break;
                case CurrentState.trace:
                    Chasing = true;
                    LookTarget(playerTransform);
                    animator.Play("walk");
                    if (MoveType == false)
                    {
                        transform.position = new Vector3(Vector3.MoveTowards(transform.position, playerTransform.position, RunSpeed * Time.deltaTime).x, 0, transform.position.z);
                    }
                    else if (MoveType == true)
                    {
                        transform.position = new Vector3(transform.position.x, 0, Vector3.MoveTowards(transform.position, playerTransform.position, RunSpeed * Time.deltaTime).z);
                    }
                    break;
                case CurrentState.Hit:
                    Hit();
                    break;
                case CurrentState.attack:
                    LookTarget(playerTransform);
                    Attack();                          
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

    void AttackEffectStart()
    {
        AttackEffect.Play();
    }

    public void OnDamage(int damage, Vector3 pos)
    {
        if (CheckCutOff())
        {
            CutOff();
        }
        CurHP -= damage;
        State = CurrentState.Hit;
        Motioning = true;
    }
       public void OnRecovery(int heal)
    {

    }

    void Attack()
    {
        Motioning = true;
        animator.Play("attack");
        if (animator.GetCurrentAnimatorStateInfo(0).IsName("attack") && animator.GetCurrentAnimatorStateInfo(0).normalizedTime <= 0.5f) //50%����
        {
            AttackArea.SetActive(false); //ù���
        }
        else if (animator.GetCurrentAnimatorStateInfo(0).IsName("attack") && (animator.GetCurrentAnimatorStateInfo(0).normalizedTime >= 0.5f && //50���̻� ~ 80����
                                                                                animator.GetCurrentAnimatorStateInfo(0).normalizedTime <= 0.7f))
        {
            AttackArea.SetActive(true);  //���ݹ��� Ȱ��ȭ
        }
        else if (animator.GetCurrentAnimatorStateInfo(0).IsName("attack") && animator.GetCurrentAnimatorStateInfo(0).normalizedTime <= 0.99f) //50%����
        {
            AttackArea.SetActive(false);
        }
        else if (animator.GetCurrentAnimatorStateInfo(0).IsName("attack") && animator.GetCurrentAnimatorStateInfo(0).normalizedTime >= 1.0f)  //100���̻�
        {
            Motioning = false;  //�������
            AttackArea.SetActive(false);
            State = CurrentState.idle;
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
        if (Motioning == false)
        {
            Vector3 dir = Target.position - this.transform.position;
            Vector3 dirXZ = new Vector3(dir.x, 0.0f, dir.z);   

            Vector3 DirR = new Vector3(100, 0, 0);
            Vector3 DirL = new Vector3(150, 0, -250);

            if (dirXZ == Vector3.zero)
                return;

            if(dir.x > 0)
            {
                this.transform.rotation = Quaternion.RotateTowards(this.transform.rotation, Quaternion.LookRotation(DirR), 400 * Time.deltaTime);
            }
            else
            {
                this.transform.rotation = Quaternion.RotateTowards(this.transform.rotation, Quaternion.LookRotation(DirL), 400 * Time.deltaTime);
            }

        }

    }
}
