using UnityEngine;
public class WireState : IState{
    private float m_MinDistance = 1.0f;  
    private Vector3 m_SaveWireAttack;           //WireAttack need force(distance) distance after end of animation
    private Vector3 m_movePosition;             //save Player Moveposition location for attack monster with wire
    private float m_DistanceToWire = 0;         //player ~ Wire Target Distance
    private float m_insurenceTimer = 0;         //For Buggy.

    public override void OnStateEnter(PlayerController player)  {     
        player.rigid.useGravity = false;

#region HitInter
    IWireEffect IWE = GetComponent<IWireEffect>();
    if(IWE != null) IWE.Hit(false);
#endregion

        if (player.SaveMonDetect)   {              // Editable Plus distance for Wire Attack
            m_SaveWireAttack = new Vector3 (player.wirePos.position.x + (6.0f * player.lookVector.x),
                player.wirePos.position.y - player.SaveBouceYPos, 0);

            player.ani.SetTrigger("WireAttack");
            m_MinDistance = 1.0f;
        }
        else    {    //if there is no monster,
            m_SaveWireAttack = player.wirePos.position;
            player.ani.SetTrigger("WireMove");
            m_MinDistance = 2.0f;
        }
    }

    public override void OnStateExcute(PlayerController player) {
        if(player.SaveMonDetect)    {
            m_movePosition = Vector3.Lerp(player.transform.position, m_SaveWireAttack, player.WireForce * Time.deltaTime);
            m_DistanceToWire = Vector3.Distance(player.transform.position,  m_SaveWireAttack);
            player.line.SetPosition(0, player.wireStart.position);
         }
        else    {
            m_movePosition = Vector3.Lerp(player.transform.position, m_SaveWireAttack, player.WireForce * Time.deltaTime);
            m_DistanceToWire = Vector3.Distance(player.transform.position, m_SaveWireAttack);
            player.line.SetPosition(0, player.wireStart.position);
            player.line.SetPosition(1, m_SaveWireAttack);
        }

        player.SetVibValue(true, 1.0f, 1.0f, 0.3f, true);

        if (m_DistanceToWire <= m_MinDistance)  {
            if (player.SaveMonDetect)   {              
                player.ani.SetTrigger("WireMoveEnd");
                player.ChangeState(PlayerState.WalkState);
            }
            else    {
                player.ani.Play("JumpFalling");
                player.ani.SetBool("FallingLoop", true);
                player.ChangeState(PlayerState.WalkState);
            }
        }
        else    {
            if(!player.SaveMonDetect)   {        //if there is no monster
                var playerRot = Quaternion.LookRotation(m_SaveWireAttack - player.transform.position).normalized;
                player.transform.rotation = Quaternion.Slerp(player.transform.rotation , playerRot ,  Time.deltaTime * 10.0f);
                player.rigid.MovePosition(m_movePosition);   
            }

            if(player.CheckGround_ForWireAttack() && player.SaveMonDetect)  {       // made zero velocity when player col with wall using attack wire.
                player.rigid.velocity = new Vector3(0, player.rigid.velocity.y);
                player.ani.SetTrigger("WireMoveEnd");
                player.AttackBoxOff(1);
                player.ChangeState(PlayerState.WalkState);
                return;
            }
            else     player.rigid.MovePosition(m_movePosition);    
        }

        //=========this func is made for insurence==========//
        var resetTimer = 1.0f;
        m_insurenceTimer += Time.deltaTime;
        if(m_insurenceTimer >= resetTimer)  {
            m_insurenceTimer = 0;
            player.SaveMonDetect = false;
            player.ani.SetTrigger("WireMoveEnd");
            player.ChangeState(PlayerState.WalkState);
        }
        //==================================+++++++++++======//
    }

    public override void OnStateExit(PlayerController player)   {    
        player.line.GetComponent<Renderer>().material = null; 
        player.SetVibValue(false, 0.0f, 0.0f, 0.0f, false);
        player.line.SetPosition(0, Vector3.zero);
        player.line.SetPosition(1, Vector3.zero);
        player.wirePos.position = Vector3.zero;
        player.LockLookTartget = false;
        player.rigid.useGravity = true;
        player.SaveMonDetect = false;
        player.line.enabled = false;
        player.ui.SP_Using = false;
        player.invinBool = false;
        player.AttackBoxOff(1);       
        player.Walk();    

        
        m_SaveWireAttack = Vector3.zero;
        m_insurenceTimer = 0;
    }
}
