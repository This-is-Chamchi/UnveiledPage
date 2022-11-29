using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

namespace LDS.Fire
{
    public class FireHead : Monster
    {
        [Header("Fire Head")]
        public GameObject damageBox;
        public GameObject body { get; set; }

        public IState Bomb { get; set; }

        protected override void Initialize()
        {
            Idle = transform.AddComponent<Idle>();
            Walk = transform.AddComponent<Walk>();
            Bomb = transform.AddComponent<Bomb>();            

            body = transform.GetChild(0).gameObject;

            base.Initialize();
        }

        protected override void Start()
        {
            base.Start();

            curEuler = rotationValue[0];
            damageBox.SetActive(false);
        }

        public override void OnDamage(int damage, Vector3 pos)
        {
            if (curState == Bomb) return;
            ChangeState(Bomb);            
        }

        public override void CutDamage()
        {
            
        }
    }

    public abstract class FireState : MonsterState
    {
        protected FireHead mon;
        protected void Awake()
        {
            mon = gameObject.GetComponent<FireHead>();
        }
    }

    public class Idle : FireState
    {
        public override void OnEnter()
        {            
            animTime = 0;            
            mon.ani.SetTrigger("Idle");
        }

        public override void OnExcute()
        {
            if (mon.CheckPlayer()) mon.ChangeState(mon.Walk);
            mon.UpdateRotate();
        }

        public override void OnExit()
        {

        }
    }

    public class Walk : FireState
    {
        public override void OnEnter()
        {
            SoundManager.PlayVFXSound("2Stage_BurningHead_Scream", transform.position);
            animTime = 0;
            mon.ani.SetTrigger("Walk");
        }

        public override void OnExcute()
        {
            if (!mon.CheckPlayer()) mon.ChangeState(mon.Idle);
            else if (mon.TargetCast(mon.attackDis)) mon.ChangeState(mon.Bomb);
            else mon.WalkToPos(mon.target.position);
            mon.UpdateRotate();
        }

        public override void OnExit()
        {

        }
    }

    public class Bomb : FireState
    {
        bool value;

        public override void OnEnter()
        {
            value = false;
            animTime = 0;
            mon.ani.SetTrigger("Bomb");
        }

        public override void OnExcute()
        {
            animTime += Time.deltaTime;
            if (animTime > 0.35f && !value)
            {
                SoundManager.PlayVFXSound("2Stage_BurnnigHead_explosion", transform.position);
                mon.damageBox.SetActive(true);
                Destroy(mon.gameObject, 0.1f);
                mon.CreateEffect("Bomb", mon.transform.position);
                mon.aliveObj.SetActive(false);
                mon.isRun = false;
                value = true;
            }
        }

        public override void OnExit()
        {

        }
    }

}
