using DG.Tweening;
using GD.MinMaxSlider;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

namespace LDS
{
    public class FortuneBunny : Monster
    {
        [Header("Fortune Bunny")]
        public Boomerang boomarang;
        [SerializeField] private Transform throwHand;
        public LayerMask stopLayer;
        [MinMaxSlider(5f, 30f)]
        public Vector2 runAwayDistance;


        public IState RunAway { get; set; }
        public IState Hide { get; set; }


        protected override void Awake()
        {
            base.Awake();

            Idle = transform.AddComponent<Idle>();
            Walk = transform.AddComponent<Walk>();
            Hit = transform.AddComponent<Hit>();
            Attack = transform.AddComponent<Attack>();
            Dead = transform.AddComponent<Dead>();
            RunAway = transform.AddComponent<RunAway>();

        }

        protected override void Initialize()
        {
            base.Initialize();
            curEuler = rotationValue[0];
        }

        public override void OnDamage(int damage, Vector3 pos)
        {
            base.OnDamage(damage, pos);
            if (curHp <= 0 && curState != RunAway) ChangeState(RunAway);
        }

        public void ShotAttack()
        {
            if (target != null && TargetCast(attackDis)) boomarang.Shot(target.position, throwHand.position);
            else boomarang.Shot(transform.position + lookVector * 5, throwHand.position);
        }
    }

    public abstract class BunnyState : MonsterState
    {
        protected FortuneBunny mon;
        protected void Awake()
        {
            mon = gameObject.GetComponent<FortuneBunny>();
        }
    }

    public class Idle : BunnyState
    {
        public override void OnEnter()
        {
            animTime = 0;
            mon.ani.SetTrigger("Idle");
        }

        public override void OnExcute()
        {
            animTime += Time.deltaTime;

            if (mon.TargetCast(mon.attackDis) && mon.GetAttackDelay() < animTime) mon.ChangeState(mon.Attack);
            else if (!mon.TargetCast(mon.attackDis) && mon.target != null && animTime > 0.2f) mon.ChangeState(mon.Walk);
            if (mon.target != null) mon.SetRotate(mon.target.position);
            mon.UpdateRotate();
        }

        public override void OnExit()
        {
            
        }
    }

    public class Walk : BunnyState
    {
        public override void OnEnter()
        {
            mon.ani.SetTrigger("Walk");
        }

        public override void OnExcute()
        {
            if (mon.TargetCast(mon.attackDis)) mon.ChangeState(mon.Attack);
            else if (mon.target == null) mon.ChangeState(mon.Idle);
            if (mon.target != null) mon.WalkToPos(mon.target.position);
            mon.UpdateRotate();
        }

        public override void OnExit()
        {

        }
    }

    public class Attack : BunnyState
    {
        public override void OnEnter()
        {
            animTime = 0;
            mon.ani.SetTrigger("Attack");
        }

        public override void OnExcute()
        {
            animTime += Time.deltaTime;
            if (animTime >= 1.5f) mon.ChangeState(mon.Idle);

        }

        public override void OnExit()
        {

        }
    }

    public class RunAway : BunnyState
    {
        float runDis;
        Vector3 runPos;
        LayerMask map;

        private void Start()
        {
            map = 1 << LayerMask.NameToLayer("Ground") | LayerMask.NameToLayer("Wall");
        }

        public override void OnEnter()
        {
            runDis = Random.Range(mon.runAwayDistance.x, mon.runAwayDistance.y);
            runPos = new Vector3(transform.position.x + runDis * -mon.lookVector.x, transform.position.y, transform.position.z);
            animTime = 0;            
            mon.ani.SetTrigger("Run");
        }

        public override void OnExcute()
        {
            animTime += Time.deltaTime;
            if (mon.StopCast(mon.stopLayer) && animTime > 1f) mon.ChangeState(mon.Idle);
            else if (mon.Distance(runPos) < 0.6f) mon.ChangeState(mon.Idle);
            if (!mon.TargetCast(1, mon.lookVector, map)) mon.WalkToPos(runPos, mon.runSpeed);
            mon.UpdateRotate();
        }

        public override void OnExit()
        {

        }
    }

    public class Hit : BunnyState
    {
        public override void OnEnter()
        {
            animTime = 0;
            EffectPoolManager.gInstance.LoadEffect("FX_Hit_Enemy", transform);
            mon.ani.SetTrigger("Hit");
        }

        public override void OnExcute()
        {
            animTime += Time.deltaTime;

            if (animTime >= 0.3f) mon.ChangeState(mon.Idle);            
        }

        public override void OnExit()
        {

        }
    }

    public class Dead : BunnyState
    {
        MeshRenderer[] meshRender;
        float CurrentTime;

        public override void OnEnter()
        {
            mon.PlaySound("Bunny_Dead");
            mon.aliveObj.SetActive(false);
            mon.sliceObj.SetActive(true);
            mon.coll.enabled = false;
            mon.ForceBody();
            meshRender = mon.sliceObj.GetComponentsInChildren<MeshRenderer>();

            foreach (var item in meshRender)
            {
                item.material = new Material(item.material);
            }
        }

        public override void OnExcute()
        {
            CurrentTime += Time.deltaTime / 3f;

            foreach (var item in meshRender)
            {
                Color color = item.material.color;
                color.a = 1.0f - CurrentTime;
                item.material.color = color;
                if (color.a <= 0) Destroy(mon.transform.parent.gameObject);
            }
        }

        public override void OnExit()
        {

        }
    }

    public class Hide : BunnyState
    {        
        public override void OnEnter()
        {
            animTime = 0;
            
        }

        public override void OnExcute()
        {
            //mon.WalkToPos()
        }

        public override void OnExit()
        {

        }
    }

    #region OldBunny
    //public class FortuneBunny : MonoBehaviour, IEntity, ICutOff
    //{
    //    public Animator ani { get; set; }
    //    public Rigidbody rigid { get; set; }
    //    public Collider coll { get; set; }

    //    [Header("[Basic Value]")]
    //    [SerializeField] private int maxHp;
    //    [SerializeField, ReadOnly] private int curHp;
    //    [SerializeField] private int attackDamage;
    //    [SerializeField] private float attackDelay;
    //    [SerializeField] private float walkSpeed;
    //    [SerializeField] private float runSpeed;

    //    [Header("[Behavior Pattern]")]
    //    public Vector3 lookVector;
    //    [SerializeField] private float searhDistance;
    //    [SerializeField] private float attackDistance;
    //    [SerializeField] private float runDistance;
    //    [SerializeField] private float returnDistance;
    //    [SerializeField] private LayerMask targetLayer;
    //    public float hideMaxTime, hideMinTime;

    //    [Header("[Edit Component]")]
    //    public GameObject baseObj;
    //    public GameObject slicedObj;
    //    private Rigidbody[] sliceRigid;
    //    [SerializeField] private Transform[] hideCave;
    //    public Boomerang boomerang;
    //    [SerializeField] private Transform shotPos;

    //    [SerializeField] private Vector3 pos;
    //    [SerializeField] private Vector3 size;

    //    private Vector3 damagePos;

    //    public Transform target;

    //    private State curState;
    //    private State prevState;

    //    public bool animPlay { get; private set; }        


    //    private void Awake()
    //    {
    //        ani = GetComponent<Animator>();
    //        rigid = GetComponent<Rigidbody>();
    //        coll = GetComponent<Collider>();

    //        sliceRigid = new Rigidbody[2];
    //        sliceRigid[0] = slicedObj.transform.GetChild(0).GetComponent<Rigidbody>();
    //        sliceRigid[1] = slicedObj.transform.GetChild(1).GetComponent<Rigidbody>();
    //    }

    //    private void Start()
    //    {
    //        boomerang.SetDamage(attackDamage);
    //        Initialize();

    //        StartCoroutine(Routine());
    //    }

    //    private void Initialize()
    //    {
    //        curHp = maxHp;
    //        SetState(new Idle());
    //        lookVector = Vector3.left;
    //    }

    //    private IEnumerator Routine()
    //    {
    //        while (true)
    //        {
    //            curState.OnExcute(this);
    //            FindPlayer();
    //            UpdateRotate();
    //            //Debug.Log("CurState : " + curState.ToString());
    //            yield return YieldInstructionCache.waitForFixedUpdate;
    //        }
    //    }

    //    public void SetState(State next)
    //    {
    //        curState = next;
    //        curState.OnEnter(this);            
    //    }

    //    public void ChangeState(State next)
    //    {
    //        prevState = curState;
    //        prevState.OnExit(this);
    //        curState = next;
    //        curState.OnEnter(this);
    //        animPlay = true;
    //    }

    //    public void WalkToPos(Vector3 pos)
    //    {

    //    }

    //    public Vector3 SelectCave()
    //    {

    //        //return Vector3.Distance(transform.position, hideCave[0].position) < Vector3.Distance(transform.position, hideCave[1].position) ? hideCave[0].position : hideCave[1].position;
    //        return transform.position.x < target.position.x ? hideCave[0].position : hideCave[1].position;
    //    }

    //    public void SpawnCave(int i)
    //    {
    //        transform.position = hideCave[i].position;
    //    }

    //    public bool CheckActiveCave()
    //    {
    //        return hideCave[0].gameObject.activeSelf && hideCave[1].gameObject.activeSelf ? true : false;
    //    }

    //    public int GetActiveCave()
    //    {
    //        var val = -1;
    //        for (int i = 0; i < 2; i++)
    //        {
    //            if (hideCave[i].gameObject.activeSelf)
    //            {
    //                val = i;
    //                break;
    //            }
    //        }
    //        if (val == -1) val = 0;
    //        return val;
    //    }

    //    public void RunAway(Vector3 pos)
    //    {
    //        var dir = transform.position.x < pos.x ? 1 : -1;
    //        rigid.velocity = new Vector3(dir * runSpeed, rigid.velocity.y);
    //    }

    //    public void Runthrough()
    //    {
    //        var dir = transform.position.x < target.position.x ? -1 : 1;
    //        lookVector = new Vector3(dir, 0);
    //        Debug.Log(dir);
    //        rigid.velocity = new Vector3(dir * (runSpeed + walkSpeed) / 2, rigid.velocity.y);
    //    }

    //    public float CheckDistance(Vector3 pos)
    //    {
    //        return Vector3.Distance(transform.position, pos);
    //    }

    //    public void WalkToTarget()
    //    {
    //        if (target == null) return;
    //        var dir = transform.position.x < target.position.x ? 1 : -1;
    //        rigid.velocity = new Vector3(dir * walkSpeed, rigid.velocity.y);
    //    }

    //    public void UpdateRotate()
    //    {                     
    //        var target = Quaternion.Euler(new Vector3(0, lookVector.x * 90));
    //        transform.rotation = Quaternion.Slerp(transform.rotation, target, Time.deltaTime * 4);
    //    }

    //    public void CheckRotate(Vector3 target)
    //    {
    //        if (target != null)
    //        {
    //            lookVector = transform.position.x < target.x ? new Vector3(1, 0, 0) : new Vector3(-1, 0);
    //        }
    //    }

    //    public void SetRotate(Vector3 dir)
    //    {
    //        lookVector = dir;
    //    }

    //    private void ShotAttack()
    //    {
    //        if (target == null) return;
    //        boomerang.Shot(target.position + new Vector3(0, 1.1f), shotPos.position);
    //    }

    //    public void AnimStart()
    //    {
    //        animPlay = true;
    //    }

    //    private void AnimEnd()
    //    {
    //        animPlay = false;
    //    }

    //    #region Interface
    //    public void OnDamage(int damage, Vector3 pos)
    //    {
    //        curHp -= damage;
    //        damagePos = pos;
    //        ChangeState(new Hit());
    //    }

    //    public void OnRecovery(int heal) { }

    //    public bool CheckCutOff()
    //    {
    //        return curHp <= 0;
    //    }

    //    public void CutDamage()
    //    {
    //        ChangeState(new Dead());
    //    }

    //    #endregion

    //    public void FindPlayer()
    //    {
    //        RaycastHit ray;
    //        if (Physics.BoxCast(transform.position, new Vector3(0.5f, 2.5f, 5), lookVector, out ray, Quaternion.identity, searhDistance, targetLayer))
    //        {
    //            target = ray.collider.transform;
    //        }
    //        else if (Physics.BoxCast(transform.position, new Vector3(0.5f, 2.5f, 5), -lookVector, out ray, Quaternion.identity, 5, targetLayer))
    //        {
    //            target = ray.collider.transform;
    //        }
    //        else target = null;
    //    }

    //    public bool CheckAttack()
    //    {
    //        return Physics.BoxCast(transform.position, new Vector3(0.5f, 2.5f, 5), lookVector, Quaternion.identity, attackDistance, targetLayer);
    //    }

    //    public bool CheckRunAway()
    //    {
    //        return Physics.BoxCast(transform.position, new Vector3(0.5f, 2.5f, 5), lookVector, Quaternion.identity, runDistance, targetLayer);
    //    }

    //    public bool CheckReturn()
    //    {
    //        return Physics.BoxCast(transform.position, new Vector3(0.5f, 2.5f, 5), -lookVector, Quaternion.identity, returnDistance, targetLayer);
    //    }

    //    private void OnDrawGizmos()
    //    {
    //        Gizmos.color = Color.red;
    //        Gizmos.DrawWireCube(transform.position + pos, size);
    //    }

    //    public void PlaySound(string name)
    //    {
    //        SoundManager.PlayVFXSound(name, transform.position);
    //    }

    //    public void ForceBody()
    //    {
    //        for (int i = 0; i < sliceRigid.Length; i++)
    //        {
    //            sliceRigid[i].AddExplosionForce(15, transform.position + Vector3.Normalize(damagePos - transform.position), 360.0f, 0.0f, ForceMode.VelocityChange);
    //        }            
    //    }
    //}

    //public interface State
    //{
    //    void OnEnter(FortuneBunny mon);
    //    void OnExcute(FortuneBunny mon);
    //    void OnExit(FortuneBunny mon);
    //}

    //public class Idle : State
    //{
    //    public void OnEnter(FortuneBunny mon)
    //    {
    //        mon.ani.SetTrigger("Idle");            
    //    }

    //    public void OnExcute(FortuneBunny mon)
    //    {
    //        //if (mon.CheckRunAway() && mon.CheckCutOff()) mon.ChangeState(new Runthrough());
    //        if (mon.CheckAttack() && !mon.boomerang.isPlay) mon.ChangeState(new Attack());
    //        else if (mon.target != null) mon.ChangeState(new Walk());            
    //        if (mon.target != null) mon.CheckRotate(mon.target.position);

    //    }

    //    public void OnExit(FortuneBunny mon)
    //    {


    //    }
    //}

    //public class Walk : State
    //{
    //    public void OnEnter(FortuneBunny mon)
    //    {
    //        mon.ani.SetBool("Walk", true);            
    //    }

    //    public void OnExcute(FortuneBunny mon)
    //    {
    //        //if (mon.CheckRunAway() && mon.CheckCutOff()) mon.ChangeState(new Runthrough());
    //        if (mon.CheckAttack() && !mon.boomerang.isPlay) mon.ChangeState(new Attack());
    //        else if (mon.target == null) mon.ChangeState(new Idle());
    //        else if (mon.target != null) mon.CheckRotate(mon.target.position);
    //        mon.WalkToTarget();
    //    }

    //    public void OnExit(FortuneBunny mon)
    //    {
    //        mon.ani.SetBool("Walk", false);

    //    }
    //}

    //public class RunAway : State
    //{
    //    Vector3 target;

    //    public void OnEnter(FortuneBunny mon)
    //    {
    //        mon.ani.SetTrigger("Run");            
    //        target = mon.SelectCave();
    //    }

    //    public void OnExcute(FortuneBunny mon)
    //    {
    //        if (mon.CheckDistance(target) < 0.4f) mon.ChangeState(new Hide());
    //        mon.RunAway(target);
    //        mon.CheckRotate(target);            
    //    }

    //    public void OnExit(FortuneBunny mon)
    //    {


    //    }

    //}

    //public class Attack : State
    //{
    //    public void OnEnter(FortuneBunny mon)
    //    {
    //        if (mon.target == null) mon.ChangeState(new Idle());
    //        mon.ani.SetTrigger("Attack");
    //        //SoundManager.PlayVFXSound("Bunny_Attack", mon.transform.position, 1, 10);            
    //    }

    //    public void OnExcute(FortuneBunny mon)
    //    {
    //        if (mon.target == null) mon.ChangeState(new Idle());
    //        if (!mon.animPlay) mon.ChangeState(new Idle());

    //    }

    //    public void OnExit(FortuneBunny mon)
    //    {


    //    }
    //}

    //public class Hit : State
    //{
    //    public void OnEnter(FortuneBunny mon)
    //    {
    //        mon.rigid.AddForce(-mon.lookVector * 12, ForceMode.Impulse);
    //        mon.ani.SetTrigger("Hit");
    //        EffectPoolManager.gInstance.LoadEffect("FX_Hit_Enemy", mon.transform);
    //    }

    //    public void OnExcute(FortuneBunny mon)
    //    {
    //        if (mon.CheckCutOff() && mon.CheckActiveCave()) mon.ChangeState(new RunAway());
    //        else if (!mon.animPlay) mon.ChangeState(new Idle());

    //    }

    //    public void OnExit(FortuneBunny mon)
    //    {


    //    }
    //}

    //public class Dead : State
    //{
    //    MeshRenderer[] meshRender;
    //    float CurrentTime;
    //    float time;       
    //    public void OnEnter(FortuneBunny mon)
    //    {
    //        mon.PlaySound("Bear_Dead");
    //        mon.coll.enabled = false;            
    //        meshRender = mon.slicedObj.GetComponentsInChildren<MeshRenderer>();
    //        foreach (var item in meshRender)
    //        {
    //            item.material = new Material(item.material);
    //        }
    //        mon.baseObj.SetActive(false);
    //        mon.slicedObj.SetActive(true);
    //        mon.PlaySound("Fortuen_Dead");
    //        mon.ForceBody();
    //        time = 0;
    //    }

    //    public void OnExcute(FortuneBunny mon)
    //    {
    //        CurrentTime += Time.deltaTime / 3f;

    //        foreach (var item in meshRender)
    //        {
    //            Color color = item.material.color;
    //            color.a = 1.0f - CurrentTime;
    //            item.material.color = color;
    //            if (color.a <= 0) GameObject.Destroy(mon.transform.parent.gameObject);
    //        }
    //    }

    //    public void OnExit(FortuneBunny mon)
    //    {


    //    }
    //}

    //public class Hide : State
    //{
    //    float time;
    //    float checkTime;

    //    public void OnEnter(FortuneBunny mon)
    //    {
    //        mon.coll.enabled = false;
    //        mon.rigid.useGravity = false;
    //        mon.rigid.velocity = Vector3.zero;
    //        time = 0;
    //        checkTime = Random.Range(mon.hideMinTime, mon.hideMaxTime);
    //        mon.transform.GetChild(1).gameObject.SetActive(false);
    //    }

    //    public void OnExcute(FortuneBunny mon)
    //    {
    //        if (!mon.CheckActiveCave()) mon.ChangeState(new Idle());
    //        time += Time.deltaTime;
    //        if (time >= checkTime)
    //        {
    //            mon.ChangeState(new Idle());
    //        }
    //    }

    //    public void OnExit(FortuneBunny mon)
    //    {
    //        mon.transform.GetChild(1).gameObject.SetActive(true);
    //        if (mon.CheckActiveCave())
    //        {
    //            var rand = Random.Range(0, 100);
    //            var ch = rand < 50 ? 0 : 1;
    //            mon.SpawnCave(ch);
    //        }
    //        else
    //        {
    //            mon.SpawnCave(mon.GetActiveCave());
    //        }
    //        mon.coll.enabled = true;
    //        mon.rigid.useGravity = true;
    //    }
    //}

    //public class Runthrough : State
    //{
    //    public void OnEnter(FortuneBunny mon)
    //    {
    //        mon.ani.SetTrigger("Run");            
    //    }

    //    public void OnExcute(FortuneBunny mon)
    //    {
    //        if (!mon.CheckReturn()) mon.ChangeState(new Idle());
    //        mon.Runthrough();            

    //    }

    //    public void OnExit(FortuneBunny mon)
    //    {


    //    }
    //}
    #endregion

}