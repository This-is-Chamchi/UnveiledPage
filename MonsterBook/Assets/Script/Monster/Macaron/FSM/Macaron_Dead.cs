using System.Collections;
using System.Collections.Generic;
using UnityEngine;



namespace MonsterFSM.MacaronFSM
{

    public class Macaron_Dead : MonsterFSMBase
    {
        private readonly float DeadTime = 3.0f;

        private Macaron MacaronMon;
        private float CurrentTiem;
        private bool isDeadForec;


        public void init(MonsterBase MonsterController)
        {
            CurrentTiem = 0.0f;
            Monster = MonsterController;
            MacaronMon = Monster as Macaron;

            //MacaronMon.gDeadObject.SetActive(true);
            //MacaronMon.gMacaronModel.SetActive(false);

            Destroy(Monster.transform.parent.gameObject, DeadTime);
        }

        public override void FixedExecute(Rigidbody rigid)
        {
            if (!isDeadForec)
            {

                //var MonsterRigid = MacaronMon.gDeadObject.GetComponentsInChildren<Rigidbody>();
                //var PlayerVector = (MacaronMon.transform.position - MacaronMon.gPlayerPosition).normalized;

                //foreach (var item in MonsterRigid)
                //{
                //    item.AddExplosionForce(MacaronMon.gDeadForce, MacaronMon.transform.position + PlayerVector, 10.0f);
                //}
                isDeadForec = true;
            }
        }

        //public override MonsterFSMBase Transition()
        //{
        //    return this;
        //}

        public override void UpdateExecute()
        {
            //var MonsterMesh = MacaronMon.gDeadObject.GetComponentsInChildren<MeshRenderer>();
            //CurrentTiem += Time.deltaTime / DeadTime;
            //
            //if (CurrentTiem > 1.0f)
            //{
            //    CurrentTiem = 1.0f;
            //}
            //foreach (var item in MonsterMesh)
            //{
            //    Color color = item.material.color;
            //    color.a = 1.0f - CurrentTiem;
            //    item.material.color = color;
            //}

        }
    }
}

