using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MonsterFSM.RollRollFSM
{

    public class RollRoll_Dead : MonsterFSMBase
    {

        private RollRoll RollRollMon;
        private float CurrentTime;
        private bool isInit;

        private MeshRenderer[] ModelingRenderer;
        private readonly float DeadTime = 3.0f;

        public void init(MonsterBase MonsterController)
        {
            isInit = true;
            Monster = MonsterController;
            RollRollMon = Monster as RollRoll;
            //RollRollMon.gRollRollDeadObject.gameObject.SetActive(true);
            //RollRollMon.gRollRollModeling.gameObject.SetActive(false);
            //ModelingRenderer = RollRollMon.gRollRollDeadObject.GetComponentsInChildren<MeshRenderer>();
            Destroy(RollRollMon.transform.parent.gameObject, DeadTime);
        }



        public override void FixedExecute(Rigidbody rigid)
        {
            if (isInit)
            {
                // Force 리펙터링
                rigid.velocity = Vector3.zero;
                //var PlayerVector = (RollRollMon.transform.position - RollRollMon.gPlayerPosition).normalized;
                //var ChildRigid = RollRollMon.gRollRollDeadObject.transform.GetComponentsInChildren<Rigidbody>();

                //foreach (var item in ChildRigid)
                //{
                //  //  item.AddExplosionForce(RollRollMon.gDeadForce, RollRollMon.transform.position + /PlayerVector, /10.0f);
                //}

                isInit = false;
            }


        }

        //public override MonsterFSMBase Transition()
        //{
        //    return this;
        //}


        public override void UpdateExecute()
        {
            
             
            //foreach (var item in ModelingRenderer)
            //{
            //    Color color = item.material.color;
            //    color.a = 1.0f - CurrentTime;
            //    item.material.color = color;
            //}
        }
    }



}

