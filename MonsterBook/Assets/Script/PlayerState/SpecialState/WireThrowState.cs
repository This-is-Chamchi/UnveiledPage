using UnityEngine;

public class WireThrowState : IState    {

    private bool isAimMonsterPosY = false;      //if monster is too high, then return wire.
    public override void OnStateEnter(PlayerController player)  {     
        player.line.enabled = true;
        isAimMonsterPosY = false;
        if (player.CheckDamage) {
            player._CheckDamage();
            return;
        }

        if(player.isMonsterCheck && (Mathf.Abs(player.wirePos.transform.position.y) - Mathf.Abs(player.transform.position.y) >= 5.0f))    {
            Debug.Log("the Monster is too high for use wire attack.");
            player.SetVibValue(true, .3f, .3f, .3f, false);
            player.line.enabled = false;
            isAimMonsterPosY = true;
            player.LockLookTartget = false;
            return;
        }

        if (player.PlayerLookat.transform.rotation.eulerAngles.z > 180) player.lookVector.x = 1;
        else player.lookVector.x = -1;
        player.line.GetComponent<Renderer>().material = player.WireMaterial[0];
        player.SaveMonDetect = player.isMonsterCheck;
        player.LockLookTartget = true;
        player.ani.SetTrigger("WireThrow");
        player.ParticlePlay("WireThrow");
    }

    public override void OnStateExcute(PlayerController player) {

        if(isAimMonsterPosY) { player.ChangeState(PlayerState.WalkState); return; }

        player.line.SetPosition(0, player.wireStart.position);
        player.line.SetPosition(1, player.wirePos.position);

        if(player.ani.GetCurrentAnimatorStateInfo(0).IsName("WireThrow") &&
        player.ani.GetCurrentAnimatorStateInfo(0).normalizedTime >= .95f)   {
            if (player.CheckDamage) player._CheckDamage();
            else    {
                player.SoundShot("Player_Wire_Attach");
                player.ChangeState(PlayerState.WireState);
            }
        }

#region HitInter
    IWireEffect IWE = GetComponent<IWireEffect>();
    if(IWE != null && !player.CheckDamage){
        IWE.Hit(true);
    }
#endregion
    }

    public override void OnStateExit(PlayerController player)   {
        if(!player.CheckDamage || !isAimMonsterPosY) {
            player.invinBool = true;
            player.line.GetComponent<Renderer>().material = null;
            player.line.GetComponent<Renderer>().material = player.WireMaterial[1];
        }
    }
}
