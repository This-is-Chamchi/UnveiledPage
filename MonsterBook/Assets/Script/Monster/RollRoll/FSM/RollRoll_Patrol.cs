
using UnityEngine;


namespace MonsterFSM.RollRollFSM
{
    public class RollRoll_Patrol : MonsterFSMBase
    {
        
        private Vector3 Jumpforce;        

        private RollRoll RollRollMon;

        private bool VisitePatrolPoint;




        public void init(MonsterBase MonsterController)
        {
            //Monster = MonsterController;
            RollRollMon = Monster as RollRoll;                 
            RollRollMon.gAnimator.SetTrigger("Walk");
            VisitePatrolPoint = false;
        }



        public override void FixedExecute(Rigidbody rigid)
        {
            AngleTurn(MovePatrolCallBack);
            Move(rigid , Monster.transform.forward , Monster.gWalkSpeed);
        }


        //public override MonsterFSMBase Transition()
        //{
        //    if (RollRollMon.gIsChase)
        //    {                
        //        return RollRollFSMCreator.CreateRunning(Monster);
        //    }
        //    else if (VisitePatrolPoint)
        //    {
        //        return RollRollFSMCreator.CreateIdle(Monster);
        //    }
        //    else if (isJump)
        //    {                
        //        return RollRollFSMCreator.CreateJump(Monster, Jumpforce);
        //    }               
        //
        //
        //    return this;
        //}

        private void MovePatrolCallBack()
        {
            VisitePatrolPoint = true;
        }


        public override void UpdateExecute()
        {            
        }
    }

}
