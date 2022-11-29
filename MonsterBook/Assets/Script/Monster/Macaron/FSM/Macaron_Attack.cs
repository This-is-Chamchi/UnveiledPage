using System.Collections;
using System.Collections.Generic;
using UnityEngine;


namespace MonsterFSM.MacaronFSM
{
    public class Macaron_Attack : MonsterFSMBase
    {

        private Macaron MacaronMon;
        private GameObject Player;
        private bool PlayerAttackCheck;
        private bool AttackTranslate;


        public void init(MonsterBase MonsterController)
        {
            Monster = MonsterController;
            MacaronMon = Monster as Macaron;
            AttackTranslate = false;
            PlayerAttackCheck = false;
            //MacaronMon.gAnimationTrigger.gisAnimationEnd = false;
            MacaronMon.gAnimator.ResetTrigger("Idle");
            //MacaronMon.gIsAttackChecker = true;
            if (Player == null)
                Player = GameObject.FindGameObjectsWithTag("Player")[0];

            if (!MacaronMon.gAttackChecer.gIsPlayerChecker)
                MacaronMon.gAnimator.SetTrigger("walk");
        }

        public override void FixedExecute(Rigidbody rigid)
        {


            Debug.Log("AttackChecker");
            if (!MacaronMon.gAttackChecer.gIsPlayerChecker)
            {
                Debug.Log("AttackChecker");
                if (!PlayerAttackCheck)
                {

                    var ResultPosition = Player.transform.position;
                    ResultPosition.y = Monster.transform.position.y;

                    Monster.transform.LookAt(ResultPosition);
                    rigid.position += Vector3.Scale(Monster.transform.forward, new Vector3(1.0f, 0.0f, 0.0f)).normalized * MacaronMon.gRunSpeed * Time.deltaTime;
                    MacaronMon.gAnimator.SetTrigger("Walk");
                }
            }
            else
            {
                if (!PlayerAttackCheck && Time.time - MacaronMon.gCurrentAttackDelay > MacaronMon.gAttackDelay)
                {
                    MacaronMon.gCurrentAttackDelay = Time.time;
                    MacaronMon.gAnimator.ResetTrigger("Hit");
                    MacaronMon.gAnimator.SetTrigger("Attack");

                    PlayerAttackCheck = true;

                }
                else
                    MacaronMon.gAnimator.SetTrigger("Idle");
            }
        }


        //public override MonsterFSMBase Transition()
        //{
        //    if (MacaronMon.AnimationTrigger.gisAnimationEnd)
        //    {
        //        return Macaron_FSMCarete.CreateIdle(Monster);
        //    }
        //
        //
        //
        //    return this;
        //}

        public override void UpdateExecute()
        {
            AttackTrigger();
        }

        private void AttackTrigger()
        {
            if (MacaronMon.gAnimationTrigger.gisEvent)
            {
                //MacaronMon.gAttackChecer.IsAnimationEvent = true;
            }
        }



    }
}


