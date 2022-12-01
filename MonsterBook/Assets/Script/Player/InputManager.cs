using System.Collections;
using UnityEngine.InputSystem;
using UnityEngine;

public class InputManager : MonoBehaviour   {
    #region No Touch
    private PlayerAction m_action;
    private PlayerController m_player;
    private float m_prevCurTime;
    private float m_JumpDelayTime = 0;
    private bool m_yesUcanJump = true;
    private bool m_yesUcanAttack = true;
    private bool m_yesUcanSkill = true;
    private bool m_yesUcanDash = true;
    #endregion

    private void Awake()    {

        m_action = new PlayerAction();
        m_player = GetComponent<PlayerController>();

        m_action.InGame.Walk.performed += val => m_player.SetWalkVector(val.ReadValue<float>());

        m_action.InGame.Walk.canceled += val => isEndWalk();

        m_action.InGame.Jump.started += val => isJump();

        m_action.InGame.Dash.started += val => isDash();

        //======================================================================================================//


        if(Gamepad.current == null){    
            //Mouse Aim
            m_action.InGame.MouseRotation.performed += val => m_player.PlayerAimMouse = val.ReadValue<Vector2>();
            m_action.InGame.MouseRotation.performed += val => isLookTarget();
            m_action.InGame.MouseRotation.started += val => PlayWireReady();
            m_action.InGame.MouseRotation.canceled += val => isLookTargetEnd();
        }
        else{
            //Xbox Right Thumstick   
            m_action.InGame.Rotate_Look.performed += val => m_player.PlayerAimObj = val.ReadValue<Vector2>();
            m_action.InGame.Rotate_Look.performed += val => isLookTarget();
            m_action.InGame.Rotate_Look.started += val => PlayWireReady();
            m_action.InGame.Rotate_Look.canceled += val => isLookTargetEnd();
        }


        //Wire Attack (after LockOn target)
        m_action.InGame.WireShot.started += val => SetSkill();

        //normal attack
        m_action.InGame.Attack.started += val => isAttack();

        m_action.InGame.SpecialAttack.started += val => isSpecialAttack();
        
        //~ consol page
        m_action.CMD.Console.started += val => Console();
        m_action.UI.Skip.started += val => GameManager.SkipCutScene();

        //if (GameManager.GetConsoleEnable())
        //{
        //    m_action.InGame.Disable();
        //} 
    }

    private void OnEnable() {m_action.Enable();}

    private void OnDisable()    {m_action.Disable();}

    private void Console()  {
        var value = !GameManager.GetConsoleEnable();
        GameManager.CallCommandWindow(value);
        GameManager.SetInGameInput(!value);      
    }

    public void SetInGameInput(bool value)  {
        if (value) m_action.InGame.Enable();
        else m_action.InGame.Disable();
    }

    public void SetInputAction(bool value)  {
        if (value) m_action.Enable();
        else m_action.Disable();
    }

    private void isEndWalk()    {m_player.SetWalkVector(0);}

    private void isAttack() {

        if(m_player.state != PlayerState.JumpState && m_player.isGround){

            if (m_yesUcanAttack &&                          //Attack Key avaliable
                !m_player.Player_Intro&&
                !m_player.LockLookTartget &&
                m_player.state != PlayerState.AttackState &&
                m_player.state != PlayerState.DashState &&
                m_player.state != PlayerState.SpecialAttackState)   {
            
                m_yesUcanAttack = false;
                if (m_player.CheckAttack() && m_player.state != PlayerState.CuttingState) m_player.ChangeState(PlayerState.CuttingState);
                else m_player.ChangeState(PlayerState.AttackState);
                if (!m_player.prevInput)StartCoroutine(InputAttackRoutine());
                else m_prevCurTime = 0;
            }
        }
        else
            m_player.ChangeState(PlayerState.JumpAttackState);
    }

    private void isSpecialAttack()  {

        if(!m_player.LockLookTartget && !m_player.Player_Intro && m_player.isGround &&
        m_player.state != PlayerState.DashState &&
        m_player.state != PlayerState.JumpState &&
        m_player.state != PlayerState.SpecialAttackState &&
        m_player.state != PlayerState.JumpAttackState &&
        m_player.ui.SP_Cur >= 100 && m_player.isGround &&
        m_player.isSecondEnable)  {
                // this skill can use only 2 stage. 
                m_player.ChangeState(PlayerState.SpecialAttackState);
        }
    }

    private void SetSkill() {

        if (m_yesUcanSkill && m_player.isLockDistance && m_player.isLookTarget && !m_player.Player_Intro &&
        m_player.state != PlayerState.AttackState && m_player.state != PlayerState.JumpAttackState &&
        m_player.state != PlayerState.DashState && m_player.state != PlayerState.WireState &&
        m_player.state != PlayerState.WireThrowState &&
        !m_player.CheckDamage)  {

            m_player.ChangeState(PlayerState.WireThrowState);
            m_yesUcanSkill = false;
        }
        StartCoroutine(WirePushDelay(2.0f));         
    }

    private void isJump()   {

        if (m_yesUcanJump &&
            m_player.isGround &&
            !m_player.Player_Intro &&
            m_player.state != PlayerState.DashState &&
            !m_player.LockLookTartget){
            if(m_player.isJump != 0)  {
                m_yesUcanJump = false;
                StartCoroutine(isJumpEnu(.5f));
                m_player.ChangeState(PlayerState.JumpState);
            }
        }
        else    return;
        StartCoroutine(JumpInputDelay(m_JumpDelayTime));         
    }

    private void isDash()   {

        if(m_yesUcanDash &&
            !m_player.Player_Intro &&
            !m_player.LockLookTartget &&
            m_player.state != PlayerState.DashState &&
            m_player.state != PlayerState.WireState &&    
             m_player.state != PlayerState.AttackState)
        {
           m_player.ChangeState(PlayerState.DashState);

            m_yesUcanDash = false;
        }
        else    return;
        StartCoroutine(DashDelay(m_player.dashDelayTime));
    }
    
    #region LookatTarget
    
    private void isLookTarget() {
        if (!m_player.LockLookTartget && !m_player.Player_Intro) m_player.isLookTarget = true;
        else    m_player.isLookTarget = false;
    }

    private void PlayWireReady()    {
        if(m_player.Player_Intro)   return;
        m_player.SoundShot("Player_Wire_Aim");    
    }

    private void isLookTargetEnd()  {
        //Stop searching target
        if(m_player.state != PlayerState.WireState && m_player.state != PlayerState.WireThrowState){    
            m_player.PlayerLookat.transform.rotation = Quaternion.identity;
            m_player.ui.SetWireAim(default, false);
            m_player.Arrow_Lookat.SetActive(false);
        }
        m_player.isLookTarget = false;
    }

    #endregion

    #region IEnumerator
    private IEnumerator InputAttackRoutine()    {        
        m_player.prevInput = true;
        while (m_player.prevInput)    {
            m_prevCurTime += Time.deltaTime;
            if (m_prevCurTime > .3f) {
                m_player.prevInput = false;
                m_yesUcanAttack = true;
                m_prevCurTime = 0f;
            }
            yield return YieldInstructionCache.waitForFixedUpdate;
        }                
    }
  
    private IEnumerator JumpInputDelay(float num)   {
        yield return YieldInstructionCache.waitForSeconds(num);
        m_yesUcanJump = true;
    }

    private IEnumerator DashDelay(float num)    {
        yield return YieldInstructionCache.waitForSeconds(num);
        m_yesUcanDash = true;
    }

    private IEnumerator WirePushDelay(float num)    {
        yield return YieldInstructionCache.waitForSeconds(num);
        m_yesUcanSkill = true;
    }

    private IEnumerator isJumpEnu(float num){
        yield return YieldInstructionCache.waitForSeconds(num);
        m_player.isJump = 1;
    }

    #endregion
}
