using System.Collections;
using UnityEngine;

public class HitState : IState  {
    private float m_HitRunningTime = 0.0f;

    public override void OnStateEnter(PlayerController player)  {
        player.invinBool = true;
        player.line.enabled = false;
        player.ani.SetTrigger("Hit");
        CameraController.CameraShaking(0.5f, 0.2f);

        player.rigid.AddForce(player.lookVector * -8, ForceMode.Impulse);
        StartCoroutine(Routine(player));
    }

    public override void OnStateExcute(PlayerController player) {
        m_HitRunningTime += Time.deltaTime;
        if (m_HitRunningTime >= 0.4f) {
            player.input.SetInputAction(true);
            m_HitRunningTime = 0;
            player.ChangeState(PlayerState.IdleState);
        }
    }

    public override void OnStateExit(PlayerController player)   {
        return;
    }

    private IEnumerator Routine(PlayerController player)    {
        player.input.SetInputAction(false);
        yield return YieldInstructionCache.waitForSeconds(player.InvinsibleTime);
        player.CheckDamage = false ;
        player.invinBool = false;
    }
}
