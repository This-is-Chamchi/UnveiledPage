using GD.MinMaxSlider;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

namespace LDS.Jelly
{
    public class JellyBear : Monster
    {
        [Header("[Jelly Bear]"),MinMaxSlider(0f, 10f)]
        public Vector2 idleTime;
        [Range(0,20)]
        public float runAttackCooldown;
        public bool runAttack = true;
        public float runAttackDistance;
        public GameObject runBox;
        public GameObject attackBox;
        public Transform attackEffectPos;
        
        public IState RunAttack { get; set; }
        public IState RunStop { get; set; }      
        
        public bool attackIng { get; set; }


        protected override void Initialize()
        {
            Idle = transform.AddComponent<Idle>();
            Hit = transform.AddComponent<Hit>();
            Patrol = transform.AddComponent<Patrol>();
            Walk = transform.AddComponent<Walk>();
            RunAttack = transform.AddComponent<RunAttack>();
            Attack = transform.AddComponent<ShieldAttack>();
            Dead = transform.AddComponent<Dead>();
            RunStop = transform.AddComponent<RunStop>();

            base.Initialize();
        }

        protected override void Start()
        {
            base.Start();

            runBox.SetActive(false);
            attackBox.SetActive(false);
        }

        public override void OnDamage(int damage, Vector3 pos)
        {
            if (target == null) return;
            var value = transform.position.x < target.position.x ? Vector3.right : Vector3.left;
            if (lookVector == value)
            {
                PlaySound("Bear_Hit_Shield");
                return;
            }
            base.OnDamage(damage, pos);
        }

        public void AttackBoxOn()
        {
            attackBox.SetActive(true);
        }

        public void AttackBoxOff()
        {
            attackBox.SetActive(false);
        }

        public void AttackEffect()
        {
            CreateEffect("Attack", attackEffectPos.position);
        }

    }

    public abstract class JellyState : MonsterState
    {        
        protected JellyBear mon;
        protected void Awake()
        {
            mon = gameObject.GetComponent<JellyBear>();
        }
    }

    public class Dead : JellyState
    {
        MeshRenderer[] meshRender;
        float CurrentTime;

        public override void OnEnter()
        {
            mon.PlaySound("Bear_Dead");
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

    public class Idle : JellyState
    {        
        float checkTime;
        public override void OnEnter()
        {
            mon.curEuler = mon.rotationValue[0];
            animTime = 0;
            checkTime = Random.Range(mon.idleTime.x, mon.idleTime.y);            
            mon.ani.SetTrigger("Idle");                                
        }

        public override void OnExcute()
        {
            animTime += Time.deltaTime;
            if (mon.attackIng)
            {
                if (animTime > 0.6f) mon.ChangeState(mon.Attack);
            }
            else if (mon.runAttack && mon.TargetCast(mon.runAttackDistance) && animTime >= 0.2f) mon.ChangeState(mon.RunAttack);
            else if (mon.TargetCast(mon.attackDis) && mon.GetAttackDelay() < animTime) mon.ChangeState(mon.Attack);
            else if (mon.CheckPlayer() && !mon.StopCast()) mon.ChangeState(mon.Walk);
            else if (animTime > checkTime) mon.ChangeState(mon.Patrol);
            mon.UpdateRotate();
        }

        public override void OnExit()
        {
            
        }
    }

    public class Hit : JellyState
    {        
        public override void OnEnter()
        {
            mon.curEuler = mon.rotationValue[0];
            animTime = 0;
            mon.rigid.AddForce(mon.lookVector * 10);
            EffectPoolManager.gInstance.LoadEffect("FX_Hit_Enemy", transform);
            mon.ani.SetTrigger("Hit");            
        }

        public override void OnExcute()
        {
            animTime += Time.deltaTime;
            if (mon.GetAttackDelay() < animTime) mon.ChangeState(mon.Idle);
        }

        public override void OnExit()
        {

        }
    }

    public class Patrol : JellyState
    {
        Vector3 target;        
        private void Start()
        {            
            target = mon.GetPatrolPoint();
        }

        public override void OnEnter()
        {
            animTime = 0;
            target = mon.GetPatrolPoint(target);
            mon.SetRotate(target);            
            mon.ani.SetTrigger("Walk");            
        }

        public override void OnExcute()
        {
            animTime += Time.deltaTime;
            if (mon.runAttack && mon.TargetCast(mon.runAttackDistance)) mon.ChangeState(mon.RunAttack);
            if (mon.TargetCast(mon.attackDis) && mon.GetAttackDelay() < animTime) mon.ChangeState(mon.Attack);
            else if (mon.CheckPlayer()) mon.ChangeState(mon.Walk);
            else if (!mon.Distance(target, 0.1f)) mon.WalkForward();
            else mon.ChangeState(mon.Idle);
            mon.UpdateRotate();
        }

        public override void OnExit()
        {

        }
    }

    public class Walk : JellyState
    {        
        public override void OnEnter()
        {
            animTime = 0;
            mon.ani.SetTrigger("Walk");           
        }

        public override void OnExcute()
        {
            animTime += Time.deltaTime;
            mon.UpdateRotate();
            if (mon.target == null) mon.ChangeState(mon.Idle);
            else if (mon.runAttack && mon.TargetCast(mon.runAttackDistance) && animTime >= 0.2f) mon.ChangeState(mon.RunAttack);
            else if (mon.TargetCast(mon.attackDis) && mon.GetAttackDelay() < animTime && !mon.attackIng)
            {
                mon.attackIng = true;
                mon.ChangeState(mon.Idle);
            }
            else mon.WalkToPos(mon.target.position);
        }

        public override void OnExit()
        {

        }
    }

    public class RunAttack : JellyState
    {
        LayerMask target;        

        private void Start()
        {
            target = 1 << LayerMask.NameToLayer("Wall") | LayerMask.NameToLayer("Ground");
        }

        public override void OnEnter()
        {
            mon.PlaySound("Bear_Rush");
            mon.curEuler = mon.rotationValue[1];
            gameObject.layer = LayerMask.NameToLayer("Fragment");
            StartCoroutine(Routine());
            animTime = 0;
            mon.SetRotate(mon.target.position);
            mon.ShotEffect("RunAttack", mon.lookVector == Vector3.right);
            //mon.ShotEffect("RunDust", mon.lookVector == Vector3.right);
            mon.ani.SetTrigger("RunAttack");
            mon.runBox.SetActive(true);
        }

        public override void OnExcute()
        {
            animTime += Time.deltaTime;
            if ((mon.TargetCast(3, mon.GetLookVector(), target) || animTime > 2.4f ))
            {
                mon.ChangeState(mon.RunStop);
            }
            mon.Run();
            mon.UpdateRotate();
        }

        public override void OnExit()
        {
            mon.StopEffect("RunAttack");            
            gameObject.layer = LayerMask.NameToLayer("Monster");
            mon.runBox.SetActive(false);
        }

        private IEnumerator Routine()
        {
            mon.runAttack = false;
            yield return YieldInstructionCache.waitForSeconds(mon.runAttackCooldown);
            mon.runAttack = true;
        }
    }

    public class RunStop : JellyState
    {
        public override void OnEnter()
        {           
            mon.ani.SetTrigger("RunAttackStop");
            animTime = 0;
        }

        public override void OnExcute()
        {
            animTime += Time.deltaTime;
            if (animTime > 0.5f) mon.ChangeState(mon.Idle);
        }

        public override void OnExit()
        {

        }
    }

    public class ShieldAttack : JellyState
    {                
        public override void OnEnter()
        {
            animTime = 0;            
            mon.ani.SetTrigger("Attack");            
        }

        public override void OnExcute()
        {
            animTime += Time.deltaTime;
            if (animTime >= 1f) mon.ChangeState(mon.Idle);
        }

        public override void OnExit()
        {
            mon.attackIng = false;
            mon.AttackBoxOff();
        }
    }

}
