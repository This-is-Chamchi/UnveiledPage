using System;
using System.Collections;
using UnityEngine;

[Serializable]
public struct DrawGiz
{    
    public Vector3 pos;
    public Vector3 size;
}

[Serializable]
public struct PatrolPoint
{
    public Transform leftPoint;
    public Transform rightPoint;
}

namespace LDS
{
    public abstract class Monster : MonoBehaviour, IEntity, ICutOff
    {
     
        [Serializable]
        public struct Rotation
        {
            public Vector2 lookRotation;
            public float rotationSpeed;
        }



        #region Component
        public Animator ani { get; set; }
        public Rigidbody rigid { get; set; }
        public Collider coll { get; set; }

        #endregion

        #region Monster Value
        [Header("[Run Monster]")]
        public bool isRun;

        [Header("[Basic Value]")]
        [SerializeField] protected int maxHp;
        [SerializeField, ReadOnly] protected int curHp;
        [SerializeField] protected int attackDamage;
        [SerializeField] protected float attackDelay;
        public float walkSpeed;
        public float runSpeed;
        [SerializeField] private float knockBackForce;

        public GameObject aliveObj;
        public GameObject sliceObj;
        protected Rigidbody[] sliceRigid;
        protected Vector3 damagePos;

        [Header("[Behavior Pattern]")]
        [SerializeField] protected LayerMask targetLayer;
        [SerializeField] protected float searchFrontDis;
        [SerializeField] protected float searchBackDis;       
        public float attackDis;
        [SerializeField] protected float walkStopDis;

        [SerializeField] protected StringParticle particle;

        public Rotation[] rotationValue;
        public Rotation curEuler { get; set; }

        [SerializeField] protected PatrolPoint point;
        [ReadOnly] public Transform target;

        [ReadOnly] public Vector3 lookVector;        
        public bool isState { get; set; }

        #endregion

        #region State
        protected IState curState;
        protected IState prevState;

        public IState Idle { get; set; }       
        public IState Hit { get; set; }
        public IState Dead { get; set; }
        public IState Attack { get; set; }
        public IState Patrol { get; set; }
        public IState Walk { get; set; }

        #endregion

        [SerializeField] protected DrawGiz DrawGizmos;

        #region Initialize
        protected virtual void Awake()
        {
            ani = GetComponent<Animator>();
            rigid = GetComponent<Rigidbody>();
            coll = GetComponent<Collider>();

            sliceRigid = new Rigidbody[sliceObj.transform.childCount];

            for (int i = 0; i < sliceRigid.Length; i++)
            {
                sliceRigid[i] = sliceObj.transform.GetChild(i).GetComponent<Rigidbody>();
            }
        }

        protected virtual void Start()
        {
            Initialize();

            if (isRun) StartCoroutine(UpdateRoutine());
        }

        #endregion

        protected virtual IEnumerator UpdateRoutine()
        {
            while (isRun)
            {                
                FindPlayer();                
                curState.OnExcute();
                yield return YieldInstructionCache.waitForFixedUpdate;
            }
        }

        protected virtual void Initialize()
        {
            curHp = maxHp;
            lookVector = Vector3.left;
            transform.rotation = Quaternion.Euler(0, curEuler.lookRotation.x, 0);
            SetState(Idle);
        }

        #region State Function

        public void SetMove(bool value)
        {
            isRun = value;
            if (value) StartCoroutine(UpdateRoutine());
        }

        public virtual void SetState(IState next)
        {
            if (curState == next || isState) return;            
            curState = next;
            curState.OnEnter();
            //Debug.LogWarning(curState.ToString());
        }

        public virtual void ChangeState(IState next)
        {
            if (curState == next || isState) return;            
            prevState = curState;
            prevState.OnExit();
            curState = next;
            curState.OnEnter();
            //Debug.LogWarning(prevState.ToString() + " ==> " + curState.ToString());
        }
        #endregion

        #region Move Function
        public virtual void WalkToPos(Vector3 pos)
        {
            var dir = transform.position.x < pos.x ? Vector3.right : Vector3.left;
            lookVector = dir;
            rigid.velocity = new Vector3(lookVector.x * walkSpeed, rigid.velocity.y);
        }

        public virtual void WalkToPos(Vector3 pos, float speed)
        {
            var dir = transform.position.x < pos.x ? Vector3.right : Vector3.left;
            lookVector = dir;
            rigid.velocity = lookVector * speed;
        }        

        public void WalkForward()
        {
            rigid.velocity = lookVector * walkSpeed;
        }

        public void Run()
        {
            rigid.velocity = lookVector * runSpeed;
        }

        public void SetRotate(bool isRight)
        {
            lookVector = isRight ? Vector3.right : Vector3.left;
        }

        public void SetRotate(Vector3 pos)
        {
            lookVector = transform.position.x < pos.x ? Vector3.right : Vector3.left;            
        }

        public void SetRotateReverse(Vector3 pos)
        {
            lookVector = transform.position.x > pos.x ? Vector3.right : Vector3.left;
        }

        public void UpdateRotate()
        {
            var targetRotation = lookVector.x == -1 ? Quaternion.Euler(0, curEuler.lookRotation.x, 0) : Quaternion.Euler(0, curEuler.lookRotation.y, 0);
            transform.rotation = Quaternion.Slerp(transform.rotation, targetRotation, Time.deltaTime * curEuler.rotationSpeed);
        }

        public bool CheckTargetRotate()
        {
            var dir = transform.position.x < target.position.x ? Vector3.right : Vector3.left;
            return lookVector == dir;
        }

        public Vector3 targetVector { get; set; }

        #endregion

        #region Anim Event
        //public void AnimStart() { animPlay = true; }
        //protected void AnimStop() { animPlay = false; }

        #endregion

        #region CheckArea
        public void FindPlayer()
        {
            RaycastHit ray;
            if (Physics.BoxCast(transform.position, new Vector3(0.5f, 5f, 5), lookVector, out ray, Quaternion.identity, searchFrontDis, targetLayer))
            {
                target = ray.collider.transform;
            }
            else if (Physics.BoxCast(transform.position, new Vector3(0.5f, 5f, 5), -lookVector, out ray, Quaternion.identity, searchBackDis, targetLayer))
            {
                target = ray.collider.transform;
            }
            else target = null;
        }

        public bool CheckPlayer()
        {
            return target != null;
        }

        public bool TargetCast(float dis)
        {
            return Physics.BoxCast(transform.position, new Vector3(0.5f, 5f, 5), lookVector, Quaternion.identity, dis, targetLayer);
        }

        public bool TargetCast(float dis, Vector3 dir)
        {
            return Physics.BoxCast(transform.position, new Vector3(0.5f, 5f, 5), dir, Quaternion.identity, dis, targetLayer);
        }

        public bool TargetCast(float dis, Vector3 dir, LayerMask target)
        {
            return Physics.BoxCast(transform.position, new Vector3(0.5f, 5f, 5), dir, Quaternion.identity, dis, target);
        }

        public bool StopCast()
        {
            return Physics.BoxCast(transform.position, new Vector3(0.5f, 5f, 5), lookVector, Quaternion.identity, walkStopDis, targetLayer);
        }

        public bool StopCast(LayerMask layer)
        {
            return Physics.BoxCast(transform.position, new Vector3(0.5f, 5f, 5), lookVector, Quaternion.identity, walkStopDis, layer);
        }

        #endregion

        #region GetSet
        public float Distance(Vector3 pos)
        {
            return Vector3.Distance(transform.position, pos);
        }

        public bool Distance(Vector3 pos, float dis = 0)
        {
            return dis >= Vector3.Distance(transform.position, pos);
        }

        public Vector3 GetPatrolPoint(Vector3 comp)
        {            
            return point.leftPoint.position == comp ? point.rightPoint.position : point.leftPoint.position; ;
        }

        public Vector3 GetPatrolPoint()
        {
            var rand = UnityEngine.Random.Range(0, 100);
            return rand < 50 ? point.leftPoint.position : point.rightPoint.position;
        }

        public float GetAttackDelay() { return attackDelay; }

        public Vector3 GetLookVector() { return lookVector; }

        private void OnDrawGizmos()
        {
            Gizmos.color = Color.red;
            Gizmos.DrawWireCube(transform.position + DrawGizmos.pos, DrawGizmos.size);
        }

        #endregion

        public void ShotEffect(string name) { particle[name].Play(); }

        public void ShotEffect(string name, bool right)
        {
            particle[name].transform.rotation = right ? Quaternion.Euler(0, 0, 0) : Quaternion.Euler(0, 180, 0);
            particle[name].Play();
        }

        public void StopEffect(string name)
        {
            particle[name].Stop();
        }

        public void CreateEffect(string name, Vector3 pos)
        {
            var eff = Instantiate(particle[name].gameObject, pos, particle[name].transform.rotation);
            Destroy(eff, particle[name].GetComponent<ParticleSystem>().duration);
        }

        public void PlaySound(string name)
        {
            //SoundManager.PlayVFXSound(name, transform.position, 1, 10);
            SoundManager.PlayVFXSound(name, transform.position);
        }

        public void ForceBody()
        {
            for (int i = 0; i < sliceRigid.Length; i++)
            {
                sliceRigid[i].AddExplosionForce(15, transform.position + Vector3.Normalize(damagePos - transform.position), 360.0f, 0.0f, ForceMode.VelocityChange);
            }
        }

        #region Interface
        public virtual void OnDamage(int damage, Vector3 pos)
        {
            curHp -= damage;
            damagePos = pos;
            Vector3 dir = (Vector3.Scale(transform.position - pos, new Vector3(1, 1, 0))).normalized * knockBackForce;

            if (curHp <= 0) curHp = 0;
            ChangeState(Hit);
        }

        public virtual void OnRecovery(int heal)
        {
            curHp += heal;
            if (curHp > maxHp) curHp = maxHp;
        }
    
        public virtual bool CheckCutOff()
        {
            return curHp <= 0;
        }

        public virtual void CutDamage()
        {
            ChangeState(Dead);
        }

        #endregion

    }

    public interface IState
    {
        void OnEnter();
        void OnExcute();
        void OnExit();
    }

    public abstract class MonsterState : MonoBehaviour, IState
    {
        protected float animTime;
        public abstract void OnEnter();
        public abstract void OnExcute();
        public abstract void OnExit();
    }


}
