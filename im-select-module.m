//
//  im-select
//
//  Code are mainly borrowed from:
//
//  - https://github.com/ybian/smartim/blob/master/im-select.m
//  - https://github.com/syohex/emacs-module-test/blob/master/module-test-core.c
//

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

#include <assert.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

#include "emacs-module.h"

int plugin_is_GPL_compatible;

static int do_switch(const char *im) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    int returnCode = 0;

    NSString *imId = [NSString stringWithUTF8String:im];
    NSDictionary *filter = [NSDictionary dictionaryWithObject:imId forKey:(NSString *)kTISPropertyInputSourceID];
    CFArrayRef keyboards = TISCreateInputSourceList((CFDictionaryRef)filter, false);
    if (keyboards) {
        TISInputSourceRef selected = (TISInputSourceRef)CFArrayGetValueAtIndex(keyboards, 0);
        returnCode = TISSelectInputSource(selected);
        CFRelease(keyboards);
    } else {
        returnCode = -1;
    }

    [pool release];

    return returnCode;
}

static char *get_current_im() {
    char *buf;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

    TISInputSourceRef current = TISCopyCurrentKeyboardInputSource();
    NSString *sourceId = (NSString *)(TISGetInputSourceProperty(current, kTISPropertyInputSourceID));
    buf = strdup([sourceId UTF8String]);
    // fprintf(stdout, "%s\n", [sourceId UTF8String]);
    CFRelease(current);

    [pool release];

    return buf;
}

static emacs_value
Fswitch_im(emacs_env *env, ptrdiff_t nargs, emacs_value args[], void *data)
{
    // printf("<<<<===>>>>\n");
    if (nargs == 0) {
        char *current_im = get_current_im();
        // printf("===>\n");
        // printf("current im = %s\n", current_im);
        emacs_value retval = env->make_string(env, (const char*)current_im, strlen(current_im));
        // printf("=>>> 0\n");
        free(current_im);
        // printf("=>>> 1\n");
        return retval;
    } else {
        // printf("=>>> 1\n");
        ptrdiff_t len = 0;
        emacs_value im_name = args[0];
        env->copy_string_contents(env, im_name, NULL, &len);
        // printf("=>>> 2\n");

        char *name = NULL;
        if (len == 0) {
            return env->intern(env, "nil");
        }
        // printf("=>>> 3\n");

        name = malloc(len);
        env->copy_string_contents(env, im_name, name, &len);
        // printf("now doing switch: %s!\n", name);
        if (do_switch(name) != 0) {
            free(name);
            return env->intern(env, "nil");
        }
        // printf("=>>> 4\n");
        free(name);
        // printf("=>>> 5\n");
        return env->intern(env, "t");
    }
}

static void
bind_function(emacs_env *env, const char *name, emacs_value Sfun)
{
	emacs_value Qfset = env->intern(env, "fset");
	emacs_value Qsym = env->intern(env, name);
	emacs_value args[] = { Qsym, Sfun };

	env->funcall(env, Qfset, 2, args);
}

static void
provide(emacs_env *env, const char *feature)
{
	emacs_value Qfeat = env->intern(env, feature);
	emacs_value Qprovide = env->intern (env, "provide");
	emacs_value args[] = { Qfeat };

	env->funcall(env, Qprovide, 1, args);
}

int
emacs_module_init(struct emacs_runtime *ert)
{
	emacs_env *env = ert->get_environment(ert);

#define DEFUN(lsym, csym, amin, amax, doc, data) \
	bind_function (env, lsym, env->make_function(env, amin, amax, csym, doc, data))

	DEFUN("osx-im-select", Fswitch_im, 0, 1, "Switch the input method", NULL);
#undef DEFUN

	provide(env, "osx-im-select");
	return 0;
}
