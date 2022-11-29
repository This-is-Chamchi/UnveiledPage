
using UnityEngine;

namespace MonsterFSM.RollRollFSM
{
    public class RollRoll_Jump : MonsterFSMBase
    {

        private bool isTransition = false;
        
        private Vector3 JumpForce;
        private bool isJump;

        private RollRoll RollRollMon;


        public void init(MonsterBase MonsterController , Vector3 Force)
        {            
            Monster = MonsterController;
            RollRollMon = Monster as RollRoll;
            JumpForce = Force;
            isJump = true;
            isTransition = false;
        }


        public override void FixedExecute(Rigidbody rigid)
        {
                        
            if (rigid.velocity.y <= 0.0f)
                isGroundCheck();
            Jump(rigid);


        }

        //public override MonsterFSMBase Transition()
        //{
        //    if (isTransition )
        //    {
        //        if (!RollRollMon.gIsChase)
        //        {
        //            isJump = false;                    
        //            return RollRollFSMCreator.CreatePatrol(Monster);
        //        }
        //
        //        else
        //        {                    
        //            return RollRollFSMCreator.CreateRunning(Monster);
        //        }
        //            
        //    }
        //        
        //    return this;
        //}

        public override void UpdateExecute()
        {

        }


        private void Jump(Rigidbody rigid)
        {
            if (isJump)
            {   
                float v_y = Mathf.Sqrt(2 * -Physics.gravity.y * JumpForce.y);
                float v_x = JumpForce.x * v_y / (2 * JumpForce.y);
                float v_z = JumpForce.z * v_y / (2 * JumpForce.y);

                Vector3  force = rigid.mass * (new Vector3(v_x  , v_y , v_z ) - rigid.velocity);
                rigid.AddForce(force , ForceMode.Impulse);
                isJump = false;
            }
        }

        private void isGroundCheck()
        {
            if (!isJump)
            {
                RaycastHit Hitinfo;
                float capsuleScale = Mathf.Max(transform.lossyScale.x, transform.lossyScale.z);
                if (Physics.CapsuleCast(transform.position, transform.position, capsuleScale * 0.5f, Vector3.down , out Hitinfo, 0.6f))
                {
                    isTransition = true;                    
                }
            }
        }
    }
}